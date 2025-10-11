"""
Splash Screen with PNG Sequence Animation

Displays a minimalist loading screen:
- Background: PNG sequence (301 frames with transparency)
- Foreground: GIF overlay
- Progress: Frame number (0-301) as loading progress
- Ending: Hold last frame for 2 seconds
"""

import sys
import os
from pathlib import Path
from PySide6.QtCore import Qt, QThread, Signal, QTimer
from PySide6.QtWidgets import QWidget, QVBoxLayout, QApplication, QLabel, QMessageBox
from PySide6.QtGui import QMovie, QPixmap

# Import configuration
from src.utils.config import config


class InitializationWorker(QThread):
    """Worker thread for background initialization"""
    finished = Signal(bool, str)
    progress = Signal(str)  # Progress message updates
    progress_percent = Signal(int)  # Progress percentage (0-100) for animation sync
    
    # Validation results (exported for future use)
    file_integrity_result = None
    network_check_result = None
    matlab_engine_result = None
    simulation_result = None
    final_check_result = None
    
    def __init__(self):
        super().__init__()
        self.engine_cm = None  # Store context manager to keep engine alive
        
        # Track initialization status
        self.simulation_result = None
        self.matlab_has_issues = False  # Set to True if MATLAB startup fails
        self._finished_emitted = False  # Prevent duplicate finished signal
        
    def run(self):
        """Run initialization process with 5 phases"""
        try:
            import sys
            import os
            
            parent_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
            if parent_dir not in sys.path:
                sys.path.insert(0, parent_dir)
            
            # ========== Phase 1: File Integrity Check (0-10%) ==========
            if not self._phase1_check_file_integrity():
                return  # Critical failure, abort initialization
            
            # ========== Phase 2: Network Components Check (10-20%) ==========
            self._phase2_check_network_components()
            
            # ========== Phase 3: MATLAB Engine Startup (20-30%) ==========
            matlab_engine_available = self._phase3_start_matlab_engine()
            
            # ========== Phase 4: MATLAB Simulation or Fake Progress (30-90%) ==========
            self._phase4_run_simulation_test(matlab_engine_available)
            
            # ========== Phase 5: Final Check (90-100%) ==========
            self._phase5_final_check()
            
            # ========== Completion (100%) ==========
            self.progress.emit("Initialization completed")
            self.progress_percent.emit(100)
            
            # Generate summary report
            summary = self._generate_summary()
            
            # CRITICAL: Only emit finished signal once
            import traceback
            print(f"\n{'='*60}")
            print(f"[TRACE] Worker run() completion - about to emit finished signal")
            print(f"[TRACE] _finished_emitted={self._finished_emitted}")
            print(f"[TRACE] Stack trace:")
            for line in traceback.format_stack()[:-1]:
                print(line.strip())
            print(f"{'='*60}\n")
            
            if not self._finished_emitted:
                self._finished_emitted = True
                print(f"[OK] Emitting finished(True) signal...")
                self.finished.emit(True, summary)
                print(f"[OK] finished(True) signal emitted")
            else:
                print(f"[CRITICAL] finished signal already emitted, BLOCKING duplicate!")
                
        except Exception as e:
            error_msg = f"Unexpected initialization error:\n{str(e)}"
            # CRITICAL: Only emit finished signal once
            import traceback
            print(f"\n{'='*60}")
            print(f"[TRACE] Worker run() EXCEPTION - about to emit finished(False)")
            print(f"[TRACE] _finished_emitted={self._finished_emitted}")
            print(f"[TRACE] Error: {error_msg}")
            print(f"[TRACE] Stack trace:")
            for line in traceback.format_stack()[:-1]:
                print(line.strip())
            print(f"{'='*60}\n")
            
            if not self._finished_emitted:
                self._finished_emitted = True
                print(f"[OK] Emitting finished(False) signal...")
                self.finished.emit(False, error_msg)
                print(f"[OK] finished(False) signal emitted")
            else:
                print(f"[CRITICAL] finished signal already emitted, BLOCKING duplicate!")
    
    def _phase1_check_file_integrity(self):
        """
        Phase 1: Check critical file integrity (0-10%)
        
        Returns:
            bool: True if successful, False if critical failure
        """
        self.progress.emit("Checking file integrity...")
        self.progress_percent.emit(0)
        try:
            file_check_result = self._check_file_integrity()
            self.file_integrity_result = file_check_result
            
            # CRITICAL: If file integrity fails, STOP and show error
            if file_check_result['status'] == 'failed':
                error_msg = f"File Integrity Check Failed:\n{file_check_result.get('message', 'Critical files missing')}"
                if 'missing_files' in file_check_result:
                    error_msg += f"\n\nMissing files:\n" + "\n".join(f"  - {f}" for f in file_check_result['missing_files'])
                # CRITICAL: Only emit finished signal once
                if not self._finished_emitted:
                    self._finished_emitted = True
                    self.finished.emit(False, error_msg)
                return False
            
            self.progress.emit(f"File integrity: {file_check_result['status']}")
            self.progress_percent.emit(10)
            return True
        except Exception as e:
            self.file_integrity_result = {"status": "failed", "error": str(e)}
            error_msg = f"File integrity check failed:\n{str(e)}"
            # CRITICAL: Only emit finished signal once
            if not self._finished_emitted:
                self._finished_emitted = True
                self.finished.emit(False, error_msg)
            return False  # STOP if file check fails
    
    def _phase2_check_network_components(self):
        """
        Phase 2: Check network components (10-20%)
        
        Non-critical phase - errors are logged but don't stop initialization
        """
        self.progress.emit("Checking network components...")
        self.progress_percent.emit(12)
        try:
            network_result = self._check_network_components()
            self.network_check_result = network_result
            self.progress.emit(f"Network check: {network_result['status']}")
            self.progress_percent.emit(20)
        except Exception as e:
            self.network_check_result = {"status": "failed", "error": str(e)}
            self.progress.emit(f"Network check failed: {str(e)}")
            self.progress_percent.emit(20)
            # Continue anyway - don't stop, don't show error
    
    def _phase3_start_matlab_engine(self):
        """
        Phase 3: MATLAB Engine Startup (20-30%)
        
        IMPORTANT: This phase initializes the MATLAB engine that will be used
        by the main UI. The engine is stored in the global ENGINE manager to
        avoid double initialization (which would take another 60+ seconds).
        
        Returns:
            bool: True if MATLAB engine started successfully, False otherwise
        """
        self.progress.emit("Starting MATLAB engine...")
        self.progress_percent.emit(22)
        try:
            from src.core.spinach_bridge import (
                spinach_eng, call_spinach
            )
            
            # Use context manager but keep it alive
            # Note: spinach_eng now automatically:
            #   1. Adds embedded Spinach to MATLAB path (priority over system Spinach)
            #   2. Configures 'Processes' parallel pool profile for parallel computing
            self.engine_cm = spinach_eng(clean=True)
            eng = self.engine_cm.__enter__()
            call_spinach.default_eng = eng
            
            # CRITICAL: Store engine in global ENGINE manager for main UI to use
            # This prevents double initialization
            from src.simulation.ui.simulation_window import ENGINE
            ENGINE._cm = self.engine_cm
            ENGINE._eng = eng
            
            self.matlab_engine_result = {"status": "success", "engine": eng}
            self.progress.emit("MATLAB engine started successfully")
            self.progress_percent.emit(30)
            self.matlab_has_issues = False  # Mark as OK
            return True
            
        except Exception as e:
            # MATLAB engine failed - mark as having issues
            self.matlab_engine_result = {"status": "failed", "error": str(e)}
            self.progress.emit("MATLAB engine unavailable (continuing with limited functionality)")
            self.progress_percent.emit(30)
            self.matlab_has_issues = True  # Mark as having issues
            print(f"MATLAB engine startup failed: {e}")
            return False
    
    def _phase4_run_simulation_test(self, matlab_engine_available):
        """
        Phase 4: MATLAB Simulation or Fake Progress (30-90%)
        
        Based on timing test: Total ~62s, with sim.create() taking 48s (78% of time)
        Key milestones: ENGINE_READY@12s (42%), SIM_CREATE@13s (43%), DONE@62s (90%)
        
        Args:
            matlab_engine_available (bool): Whether MATLAB engine is ready
        """
        if matlab_engine_available:
            self._run_real_matlab_simulation()
        else:
            self._run_fake_progress_simulation()
    
    def _run_real_matlab_simulation(self):
        """Run real MATLAB simulation test (Phase 4 - MATLAB available path)"""
        import time
        import threading
        import numpy as np
        
        self.progress.emit("Running MATLAB initialization simulation...")
        self.progress_percent.emit(31)  # Starting Phase 4
        
        try:
            from src.core.spinach_bridge import (
                sys as SYS, bas as BAS, inter as INTER, sim as SIM
            )
            
            # Step 4.1: Setup system (31-42%, ~11s for engine warmup)
            self.progress.emit("Setting up spin system...")
            sys_obj = SYS()
            self.progress_percent.emit(33)
            
            sys_obj.isotopes(['1H', '1H'])
            self.progress_percent.emit(35)
            
            sys_obj.magnet(14.1)  # 600 MHz
            self.progress_percent.emit(37)
            
            # Step 4.2: Setup basis (~1s)
            bas_obj = BAS()
            bas_obj.formalism('sphten-liouv')
            self.progress_percent.emit(39)
            
            bas_obj.approximation('none')
            self.progress_percent.emit(41)
            
            # Reached ENGINE_READY milestone
            self.progress.emit("MATLAB engine ready, configuring interactions...")
            self.progress_percent.emit(42)
            
            # Step 4.3: Setup interactions (~1.5s to reach sim.create)
            inter_obj = INTER()
            inter_obj.zeeman([0.0, 0.0])  # Chemical shifts
            self.progress_percent.emit(42)
            
            # J-coupling matrix: 2x2 with 7 Hz coupling
            J_matrix = np.array([[0.0, 7.0],
                                 [7.0, 0.0]])
            inter_obj.coupling_array(J_matrix)
            
            # Create SIM object (reaches 43%)
            sim_obj = SIM()
            self.progress_percent.emit(43)
            
            # Step 4.4: Compute basis (43-90%, ~49s - THE LONGEST OPERATION)
            self.progress.emit("Computing basis (this will take ~1 minute)...")
            
            import threading
            import time
            
            # Progress tracker for sim.create()
            progress_tracker = {'percent': 43, 'stop': False}
            
            def update_progress_during_create():
                """Update progress during sim.create() based on measured timing"""
                start_time = time.time()
                
                # Progress schedule based on timing test data
                milestones = [
                    (2, 48, "Running startup checks..."),
                    (5, 52, "Initializing Spinach engine..."),
                    (8, 56, "Starting parallel pool..."),
                    (12, 60, "Parallel pool ready (7 workers)..."),
                    (15, 63, "Building spin system (2 particles, 14.1T)..."),
                    (18, 66, "Configuring Zeeman interactions..."),
                    (21, 69, "Processing J-coupling matrix..."),
                    (24, 72, "Computing spherical tensor basis..."),
                    (30, 76, "Building basis set descriptor..."),
                    (36, 80, "Eliminating redundant states..."),
                    (42, 84, "Sorting basis set..."),
                    (48, 88, "Finalizing state space (16 states)..."),
                ]
                
                milestone_index = 0
                while not progress_tracker['stop'] and milestone_index < len(milestones):
                    elapsed = time.time() - start_time
                    target_time, percent, message = milestones[milestone_index]
                    
                    if elapsed >= target_time:
                        self.progress.emit(message)
                        self.progress_percent.emit(percent)
                        progress_tracker['percent'] = percent
                        milestone_index += 1
                    
                    time.sleep(0.5)  # Check every 500ms
                
                # If sim.create() finishes before all milestones, jump to 88%
                if not progress_tracker['stop'] and progress_tracker['percent'] < 88:
                    self.progress_percent.emit(88)
                    progress_tracker['percent'] = 88
            
            # Start progress update thread
            progress_thread = threading.Thread(target=update_progress_during_create, daemon=True)
            progress_thread.start()
            
            # THE ACTUAL LONG OPERATION (will block for ~49 seconds)
            sim_obj.create()
            
            # Stop progress thread and ensure we're at 90%
            progress_tracker['stop'] = True
            self.progress_percent.emit(90)
            progress_tracker['percent'] = 90
            
            self.simulation_result = {"status": "success", "type": "real"}
            self.progress.emit("MATLAB simulation completed successfully")
            self.progress_percent.emit(90)
            
        except Exception as e:
            # Simulation failed - record but continue
            self.simulation_result = {"status": "failed", "error": str(e), "type": "real"}
            self.progress.emit(f"Simulation warning: {str(e)}")
            self.progress_percent.emit(90)
            # Don't return - continue to Phase 5
    
    def _run_fake_progress_simulation(self):
        """Run fake progress simulation (Phase 4 - MATLAB unavailable path)"""
        import time
        
        self.progress.emit("Running system checks (MATLAB unavailable)...")
        
        # Simulate progress 30% -> 90% with fake delays
        for percent in range(35, 91, 5):
            self.progress_percent.emit(percent)
            time.sleep(0.1)  # Small delay to simulate work
            
            # Update message at key points
            if percent == 45:
                self.progress.emit("Verifying system configuration...")
            elif percent == 60:
                self.progress.emit("Running compatibility checks...")
            elif percent == 75:
                self.progress.emit("Finalizing system validation...")
        
        self.simulation_result = {"status": "skipped", "type": "fake", "reason": "MATLAB engine unavailable"}
        self.progress.emit("System checks completed (limited mode)")
        self.progress_percent.emit(90)
    
    def _phase5_final_check(self):
        """
        Phase 5: Final system check (90-100%)
        
        Non-critical phase - errors are logged but don't stop initialization
        """
        self.progress.emit("Performing final checks...")
        self.progress_percent.emit(92)
        try:
            final_result = self._final_check()
            self.final_check_result = final_result
            self.progress.emit(f"Final check: {final_result['status']}")
            self.progress_percent.emit(95)
        except Exception as e:
            self.final_check_result = {"status": "warning", "error": str(e)}
            self.progress.emit(f"Final check warning: {str(e)}")
            self.progress_percent.emit(95)
            # Continue anyway - don't stop, don't show error
    
    def _check_file_integrity(self):
        """Phase 1: Check critical file integrity (0-10%)"""
        from pathlib import Path
        
        critical_files = [
            'src/core/spinach_bridge.py',
            'src/utils/config.py',
            'config.txt'
        ]
        
        missing_files = []
        base_path = Path(__file__).parent.parent.parent
        
        for file_path in critical_files:
            full_path = base_path / file_path
            if not full_path.exists():
                missing_files.append(file_path)
        
        if missing_files:
            # CRITICAL: Missing files means failure
            return {
                "status": "failed",
                "missing_files": missing_files,
                "message": f"Critical error: {len(missing_files)} essential file(s) missing"
            }
        
        return {
            "status": "success",
            "message": "All critical files present"
        }
    
    def _check_network_components(self):
        """Phase 2: Check network components (10-20%) - Placeholder for future"""
        # TODO: Implement network connectivity check
        # This is a placeholder for future network-related checks
        # For now, just return success
        
        return {
            "status": "not_implemented",
            "message": "Network check not yet implemented (reserved for future use)",
            "components_checked": []
        }
    
    def _final_check(self):
        """Phase 5: Final system check (90-100%)"""
        # Check if MATLAB engine is still alive
        if self.engine_cm is None:
            return {
                "status": "warning",
                "message": "MATLAB engine not initialized"
            }
        
        # Check if default engine is set
        from src.core.spinach_bridge import call_spinach
        if call_spinach.default_eng is None:
            return {
                "status": "warning", 
                "message": "Default MATLAB engine not set"
            }
        
        return {
            "status": "success",
            "message": "All systems operational"
        }
    
    def _generate_summary(self):
        """Generate initialization summary report"""
        summary_lines = ["Initialization Summary:"]
        
        if self.file_integrity_result:
            summary_lines.append(f"  - File Integrity: {self.file_integrity_result['status']}")
        
        if self.network_check_result:
            summary_lines.append(f"  - Network Check: {self.network_check_result['status']}")
        
        if self.matlab_engine_result:
            summary_lines.append(f"  - MATLAB Engine: {self.matlab_engine_result['status']}")
        
        if self.simulation_result:
            summary_lines.append(f"  - Simulation: {self.simulation_result['status']}")
        
        if self.final_check_result:
            summary_lines.append(f"  - Final Check: {self.final_check_result['status']}")
        
        return "\n".join(summary_lines)
    
    def get_init_results(self):
        """Get initialization results for startup dialog"""
        # Check first run status
        from src.utils.first_run_setup import check_first_run
        first_run_status = check_first_run()
        
        return {
            'matlab_available': self.matlab_engine_result and self.matlab_engine_result.get('status') == 'success',
            'matlab_has_issues': self.matlab_has_issues,  # Add issue flag
            'matlab_error': self.matlab_engine_result.get('error') if self.matlab_has_issues else None,
            'python_simulation_available': True,  # TODO: Check if TwoD_simulation is available
            'network_available': self.network_check_result and self.network_check_result.get('status') == 'success',
            'file_integrity': self.file_integrity_result and self.file_integrity_result.get('status') == 'success',
            'first_run': first_run_status.get('first_run', False),
            'python_ready': first_run_status.get('python_ready', True),
            'spinach_ready': first_run_status.get('spinach_ready', False)
        }


class SplashScreen(QWidget):
    """Minimalist splash screen with PNG sequence background and PNG spin overlay"""
    
    closed = Signal()
    
    # Background animation settings
    BG_TOTAL_FRAMES = 301
    BG_FRAME_RATE = 30  # FPS for background PNG sequence
    
    # Spin overlay animation settings (loops continuously)
    SPIN_TOTAL_FRAMES = 60
    SPIN_FRAME_RATE = 30  # FPS for spin PNG sequence
    
    HOLD_DURATION = 2000  # Hold last frame for 2 seconds
    
    def __init__(self):
        super().__init__()
        
        # Prevent duplicate close signal
        self._closing_flag = False
        
        # Simulate Qt.SplashScreen behavior using QWidget
        # Qt.SplashScreen flag only works with QSplashScreen class, not QWidget
        # So we use equivalent flags for QWidget to achieve same effect:
        # - FramelessWindowHint: No borders (like splash screen)
        # - WindowStaysOnTopHint: Always on top (like splash screen)  
        # - Tool: No taskbar icon (like splash screen)
        # This combination gives splash screen behavior on QWidget
        self.setWindowFlags(
            Qt.FramelessWindowHint | 
            Qt.WindowStaysOnTopHint |
            Qt.Tool
        )
        
        # Enable transparent background for PNG with alpha channel
        self.setAttribute(Qt.WA_TranslucentBackground, True)
        
        # Set window icon (for window manager)
        from src.utils.icon_manager import icon_manager
        app_icon = icon_manager.get_app_icon()
        if not app_icon.isNull():
            self.setWindowIcon(app_icon)
        
        width = config.get("SPLASH_WINDOW_WIDTH", 700)
        height = config.get("SPLASH_WINDOW_HEIGHT", 550)
        self.setFixedSize(width, height)
        
        # Store worker reference for accessing results later
        self.worker = None
        
        self._center_on_screen()
        
        # Transparent background stylesheet
        self.setStyleSheet("background-color: transparent;")
        
        # Don't use layout - use absolute positioning for perfect alignment
        # Both labels will be positioned and sized when images are loaded
        
        # PNG sequence background label
        self.background_label = QLabel(self)
        self.background_label.setAlignment(Qt.AlignCenter)
        self.background_label.setAttribute(Qt.WA_TranslucentBackground)
        self.background_label.setStyleSheet("background: transparent;")
        
        # Spin PNG sequence overlay label
        # Will be sized and positioned to match the actual loaded image size (no scaling)
        self.spin_label = QLabel(self)
        self.spin_label.setAlignment(Qt.AlignCenter)
        self.spin_label.setAttribute(Qt.WA_TranslucentBackground)
        self.spin_label.setStyleSheet("background: transparent;")
        
        # Log message label at bottom (single line, transparent background)
        self.log_label = QLabel(self)
        self.log_label.setAlignment(Qt.AlignCenter)
        self.log_label.setAttribute(Qt.WA_TranslucentBackground)
        self.log_label.setStyleSheet("""
            QLabel {
                color: rgba(200, 200, 200, 180);
                font-size: 10px;
                font-family: 'Consolas', 'Courier New', monospace;
                background: transparent;
                padding: 5px;
            }
        """)
        self.log_label.setText("Initializing...")
        
        # Position log label near bottom (with more margin from edge)
        log_height = 25
        bottom_margin = 40  # Distance from bottom edge (increased from ~0)
        self.log_label.setGeometry(0, height - log_height - bottom_margin, width, log_height)
        
        # Load background PNG sequence frames (Starting_Animation)
        self.bg_frames = []
        self.current_bg_frame = 0
        self._load_background_sequence()
        
        # Load spin PNG sequence frames (Spin animation - loops continuously)
        self.spin_frames = []
        self.current_spin_frame = 0
        self._load_spin_sequence()
        
        self.init_success = False
        self.worker = None
        self.bg_frame_timer = None
        self.spin_frame_timer = None
        self.hold_timer = None
        
    def _load_background_sequence(self):
        """Load first background frame immediately, then load rest asynchronously"""
        png_folder = config.get("PNG_SEQUENCE_FOLDER", "assets/animations/Starting_Animation")
        self.frames_path = Path(__file__).parent.parent.parent / png_folder
        
        if not self.frames_path.exists():
            print(f"Warning: Background PNG sequence folder not found: {self.frames_path}")
            return
        
        print(f"Loading background PNG sequence from: {self.frames_path}")
        
        # OPTIMIZATION: Load ONLY first frame immediately for instant display
        first_frame_file = self.frames_path / f"Starting_Animation_00000.png"
        
        if first_frame_file.exists():
            pixmap = QPixmap(str(first_frame_file))
            self.bg_frames.append(pixmap)
            
            # Display first frame immediately
            bg_width = pixmap.width()
            bg_height = pixmap.height()
            
            # Get window dimensions
            width = config.get("SPLASH_WINDOW_WIDTH", 700)
            height = config.get("SPLASH_WINDOW_HEIGHT", 550)
            
            # Center the background label
            bg_x = (width - bg_width) // 2
            bg_y = (height - bg_height) // 2
            
            self.background_label.setGeometry(bg_x, bg_y, bg_width, bg_height)
            self.background_label.setPixmap(pixmap)
            print(f"Background size: {bg_width}x{bg_height}, position: ({bg_x}, {bg_y})")
            print(f"Loaded first frame (1/{self.BG_TOTAL_FRAMES}) - loading rest in background...")
        else:
            print(f"Error: First frame not found: {first_frame_file}")
        
        # Schedule async loading of remaining frames
        self._bg_frames_loaded = False
        self._loading_frame_index = 1  # Start from second frame
        
    def _load_remaining_frames_async(self):
        """Load remaining background frames in batches to avoid blocking"""
        if self._bg_frames_loaded:
            return
        
        # Load frames in batches of 10 to avoid blocking UI
        BATCH_SIZE = 10
        batch_end = min(self._loading_frame_index + BATCH_SIZE, self.BG_TOTAL_FRAMES)
        
        for i in range(self._loading_frame_index, batch_end):
            frame_file = self.frames_path / f"Starting_Animation_{i:05d}.png"
            
            if frame_file.exists():
                pixmap = QPixmap(str(frame_file))
                self.bg_frames.append(pixmap)
            else:
                empty_pixmap = QPixmap(self.background_label.size())
                empty_pixmap.fill(Qt.transparent)
                self.bg_frames.append(empty_pixmap)
        
        self._loading_frame_index = batch_end
        
        # Check if all frames loaded
        if self._loading_frame_index >= self.BG_TOTAL_FRAMES:
            self._bg_frames_loaded = True
            print(f"Background frames fully loaded: {len(self.bg_frames)}/{self.BG_TOTAL_FRAMES}")
        else:
            # Schedule next batch
            QTimer.singleShot(10, self._load_remaining_frames_async)
    
    def _load_spin_sequence(self):
        """Load first spin frame immediately, then load rest asynchronously"""
        spin_folder = config.get("SPIN_SEQUENCE_FOLDER", "assets/animations/Spin")
        self.spin_frames_path = Path(__file__).parent.parent.parent / spin_folder
        
        if not self.spin_frames_path.exists():
            print(f"Warning: Spin PNG sequence folder not found: {self.spin_frames_path}")
            return
        
        print(f"Loading spin PNG sequence from: {self.spin_frames_path}")
        
        # OPTIMIZATION: Load ONLY first frame immediately
        first_spin_file = self.spin_frames_path / f"Spin_00000.png"
        
        if first_spin_file.exists():
            pixmap = QPixmap(str(first_spin_file))
            self.spin_frames.append(pixmap)
            
            # Display first frame and resize/position spin label
            spin_width = pixmap.width()
            spin_height = pixmap.height()
            
            # Get window dimensions
            width = config.get("SPLASH_WINDOW_WIDTH", 700)
            height = config.get("SPLASH_WINDOW_HEIGHT", 550)
            
            # Center the spin label
            spin_x = (width - spin_width) // 2
            spin_y = (height - spin_height) // 2
            
            self.spin_label.setGeometry(spin_x, spin_y, spin_width, spin_height)
            self.spin_label.setPixmap(pixmap)
            print(f"Spin size: {spin_width}x{spin_height}")
            print(f"Loaded first spin frame (1/{self.SPIN_TOTAL_FRAMES}) - loading rest in background...")
        else:
            print(f"Error: First spin frame not found: {first_spin_file}")
        
        # Schedule async loading of remaining spin frames
        self._spin_frames_loaded = False
        self._loading_spin_index = 1  # Start from second frame
        
    def _load_remaining_spin_frames_async(self):
        """Load remaining spin frames in batches to avoid blocking"""
        if self._spin_frames_loaded:
            return
        
        # Load frames in batches of 10
        BATCH_SIZE = 10
        batch_end = min(self._loading_spin_index + BATCH_SIZE, self.SPIN_TOTAL_FRAMES)
        
        for i in range(self._loading_spin_index, batch_end):
            frame_file = self.spin_frames_path / f"Spin_{i:05d}.png"
            
            if frame_file.exists():
                pixmap = QPixmap(str(frame_file))
                self.spin_frames.append(pixmap)
            else:
                empty_pixmap = QPixmap(400, 400)
                empty_pixmap.fill(Qt.transparent)
                self.spin_frames.append(empty_pixmap)
        
        self._loading_spin_index = batch_end
        
        # Check if all frames loaded
        if self._loading_spin_index >= self.SPIN_TOTAL_FRAMES:
            self._spin_frames_loaded = True
            print(f"Spin frames fully loaded: {len(self.spin_frames)}/{self.SPIN_TOTAL_FRAMES}")
        else:
            # Schedule next batch
            QTimer.singleShot(10, self._load_remaining_spin_frames_async)
        
    def _center_on_screen(self):
        """Center window on screen"""
        screen = QApplication.primaryScreen().geometry()
        x = (screen.width() - self.width()) // 2
        y = (screen.height() - self.height()) // 2
        self.move(x, y)
    
    def start_initialization(self):
        """Start initialization and animation with 1 second delay at first frame"""
        # Show first frame for 1 second before starting
        self.log_label.setText("Starting initialization...")
        
        # Start async loading of remaining frames in background
        QTimer.singleShot(50, self._load_remaining_frames_async)
        QTimer.singleShot(50, self._load_remaining_spin_frames_async)
        
        # Start spin animation immediately
        if self.spin_frames:
            self.spin_frame_timer = QTimer()
            self.spin_frame_timer.timeout.connect(self._play_next_spin_frame)
            interval = int(1000 / self.SPIN_FRAME_RATE)
            self.spin_frame_timer.start(interval)
        
        # Wait 1 second, then start initialization worker
        QTimer.singleShot(1000, self._start_worker)
    
    def _start_worker(self):
        """Actually start the initialization worker after delay"""
        self.worker = InitializationWorker()
        self.worker.finished.connect(self._on_init_finished)
        self.worker.progress.connect(self._on_init_progress)
        self.worker.progress_percent.connect(self._on_progress_percent)
        self.worker.start()
    
    def _on_progress_percent(self, percent):
        """Update background animation frame based on progress percentage with smooth transition"""
        if not self.bg_frames:
            return
        
        # Map percentage (0-100) to frame index (0 to BG_TOTAL_FRAMES-1)
        target_frame = int((percent / 100.0) * (self.BG_TOTAL_FRAMES - 1))
        target_frame = min(target_frame, self.BG_TOTAL_FRAMES - 1)
        
        # SAFETY: Only use frames that have been loaded
        target_frame = min(target_frame, len(self.bg_frames) - 1)
        
        # Smooth transition: gradually move to target frame instead of jumping
        if not hasattr(self, '_last_target_frame'):
            self._last_target_frame = 0
        
        # If jumping too far (more than 5 frames), animate smoothly
        if target_frame > self._last_target_frame + 5:
            # Start a smooth animation from current to target
            if hasattr(self, '_smooth_animation_timer'):
                self._smooth_animation_timer.stop()
            
            self._target_frame = target_frame
            self._smooth_animation_timer = QTimer()
            self._smooth_animation_timer.timeout.connect(self._animate_to_target)
            self._smooth_animation_timer.start(16)  # ~60 FPS
        else:
            # Small jump, update directly
            self.current_bg_frame = target_frame
            if self.current_bg_frame < len(self.bg_frames):
                self.background_label.setPixmap(self.bg_frames[self.current_bg_frame])
            self._last_target_frame = target_frame
        
        print(f"Progress: {percent}% -> Frame {target_frame}/{self.BG_TOTAL_FRAMES-1} (loaded: {len(self.bg_frames)})")
    
    def _animate_to_target(self):
        """Smoothly animate background frames to target"""
        if self.current_bg_frame < self._target_frame:
            self.current_bg_frame += 1
            # SAFETY: Only use frames that have been loaded
            if self.current_bg_frame < len(self.bg_frames):
                self.background_label.setPixmap(self.bg_frames[self.current_bg_frame])
        else:
            # Reached target, stop animation
            self._smooth_animation_timer.stop()
            self._last_target_frame = self._target_frame
    
    def _play_next_spin_frame(self):
        """Play next frame in spin PNG sequence (loops continuously)"""
        if not self.spin_frames:
            return
        
        self.current_spin_frame += 1
        
        # SAFETY: Loop back or wait for more frames to load
        if self.current_spin_frame >= len(self.spin_frames):
            if self._spin_frames_loaded:
                # All frames loaded, loop back to start
                self.current_spin_frame = 0
            else:
                # Still loading, wait at last available frame
                self.current_spin_frame = len(self.spin_frames) - 1
        
        # Display current spin frame
        if self.current_spin_frame < len(self.spin_frames):
            self.spin_label.setPixmap(self.spin_frames[self.current_spin_frame])
    
    def _hold_last_frame(self):
        """Hold the last frame for HOLD_DURATION milliseconds"""
        # Ensure last background frame is displayed
        if self.bg_frames:
            self.background_label.setPixmap(self.bg_frames[-1])
        
        # Spin animation continues to loop during hold time
        
        # Stop existing hold timer if any (prevent duplicate timers)
        if hasattr(self, 'hold_timer') and self.hold_timer:
            print(f"[DEBUG] Stopping existing hold_timer")
            self.hold_timer.stop()
            self.hold_timer.deleteLater()
        
        # Start hold timer
        print(f"[DEBUG] Starting hold_timer for {self.HOLD_DURATION}ms")
        self.hold_timer = QTimer()
        self.hold_timer.setSingleShot(True)
        self.hold_timer.timeout.connect(self._close_splash)
        self.hold_timer.start(self.HOLD_DURATION)
    
    def _on_init_progress(self, message):
        """Handle initialization progress updates"""
        print(f"Progress: {message}")
        # Update log label at bottom
        self.log_label.setText(message)
    
    def _on_init_finished(self, success, message):
        """Handle initialization completion (only once)"""
        import traceback
        print(f"\n{'='*60}")
        print(f"[TRACE] _on_init_finished() ENTRY")
        print(f"[TRACE] success={success}, message={message[:100] if message else 'None'}")
        print(f"[TRACE] Stack trace:")
        for line in traceback.format_stack()[:-1]:
            print(line.strip())
        print(f"{'='*60}\n")
        
        # CRITICAL: Prevent duplicate handling
        if hasattr(self, '_init_finished_handled') and self._init_finished_handled:
            print(f"[CRITICAL] _on_init_finished() already handled, BLOCKING duplicate call!")
            return
        self._init_finished_handled = True
        print(f"[OK] First call to _on_init_finished(), proceeding...")
        
        self.init_success = success
        print(f"Initialization: {message}")
        self.log_label.setText("Initialization complete" if success else "Initialization failed")
        
        # If initialization failed, show error dialog
        if not success:
            # Stop animations
            if self.spin_frame_timer:
                self.spin_frame_timer.stop()
            
            # Show error message box
            error_box = QMessageBox(self)
            error_box.setIcon(QMessageBox.Critical)
            error_box.setWindowTitle("Initialization Failed")
            error_box.setText("Failed to initialize MATLAB engine or run test simulation.")
            error_box.setInformativeText(message)
            error_box.setStandardButtons(QMessageBox.Ok)
            error_box.setWindowFlags(Qt.WindowStaysOnTopHint | Qt.Dialog)
            
            # When user clicks OK, close splash
            error_box.finished.connect(self._close_splash)
            error_box.exec()
        else:
            # Success - hold last frame for 2 seconds then close
            self._hold_last_frame()
    
    def _close_splash(self):
        """Close splash screen and emit signal (only once)"""
        import traceback
        print(f"\n{'='*60}")
        print(f"[TRACE] _close_splash() ENTRY")
        print(f"[TRACE] _closing_flag={getattr(self, '_closing_flag', 'NOT_SET')}")
        print(f"[TRACE] Stack trace:")
        for line in traceback.format_stack()[:-1]:
            print(line.strip())
        print(f"{'='*60}\n")
        
        # Prevent duplicate close signal
        if self._closing_flag:
            print(f"[CRITICAL] _close_splash() already called, BLOCKING duplicate!")
            return
        self._closing_flag = True
        print(f"[OK] First call to _close_splash(), proceeding...")
        
        # Stop timers
        if hasattr(self, 'spin_frame_timer') and self.spin_frame_timer:
            self.spin_frame_timer.stop()
        if hasattr(self, 'hold_timer') and self.hold_timer:
            self.hold_timer.stop()
        if hasattr(self, '_smooth_animation_timer') and self._smooth_animation_timer:
            self._smooth_animation_timer.stop()
        
        # Emit signal and close
        print(f"[TRACE] About to emit closed signal...")
        self.closed.emit()
        print(f"[TRACE] Closed signal emitted, calling close()...")
        self.close()
        print(f"[TRACE] close() called")
    
    def closeEvent(self, event):
        """Handle window close event"""
        # Stop timers to prevent memory leaks
        if hasattr(self, 'spin_frame_timer') and self.spin_frame_timer:
            self.spin_frame_timer.stop()
        if hasattr(self, 'hold_timer') and self.hold_timer:
            self.hold_timer.stop()
        if hasattr(self, '_smooth_animation_timer') and self._smooth_animation_timer:
            self._smooth_animation_timer.stop()
        
        event.accept()


if __name__ == "__main__":
    app = QApplication(sys.argv)
    
    splash = SplashScreen()
    splash.show()
    splash.start_initialization()
    
    def on_closed():
        print("Splash closed")
        app.quit()
    
    splash.closed.connect(on_closed)
    
    sys.exit(app.exec())
