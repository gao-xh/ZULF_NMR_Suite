"""
Startup Configuration Dialog

Shows after splash screen initialization, allows user to select:
- Simulation backend: MATLAB Spinach vs Pure Python
- Execution mode: Local vs Workstation (network)
- Other startup options

Based on initialization results from splash screen.
"""

from PySide6.QtCore import Qt, Signal
from PySide6.QtWidgets import (
    QDialog, QVBoxLayout, QHBoxLayout, QLabel, QPushButton,
    QGroupBox, QRadioButton, QCheckBox, QButtonGroup, QFrame
)
from PySide6.QtWidgets import QLineEdit, QFileDialog
from PySide6.QtGui import QFont, QPixmap

from src.utils.config import config
from src.utils.icon_manager import icon_manager


class StartupDialog(QDialog):
    """
    Startup configuration dialog shown after initialization.
    
    Allows user to choose simulation backend and execution mode
    based on what was detected during initialization.
    """
    
    # Signals
    config_selected = Signal(dict)  # Emits selected configuration
    
    def __init__(self, init_results=None, parent=None):
        """
        Initialize startup dialog.
        
        Args:
            init_results: Dictionary containing initialization results from splash screen
                {
                    'matlab_available': bool,
                    'python_simulation_available': bool,
                    'network_available': bool,
                    'file_integrity': bool
                }
        """
        super().__init__(parent)
        
        self.init_results = init_results or {}
        self.selected_config = {
            'use_matlab': True,  # True = use MATLAB (if available), False = use Python
            'execution': 'local',  # 'local' or 'workstation'
            'ui_only_mode': False
        }
        # Store user-provided paths/options
        self.selected_config.update({
            'matlab_path': None,
            'configure_matlab_engine': False,
            'configure_embedded_spinach': False,
            'skip_matlab': False,
        })
        
        self.setup_ui()
        self.update_availability()
    
    def setup_ui(self):
        """Setup the dialog UI"""
        self.setWindowTitle(f"{config.app_name} - Startup Configuration")
        self.setWindowIcon(icon_manager.get_app_icon())
        self.setModal(True)
        self.setMinimumWidth(600)
        self.setMinimumHeight(500)
        
        # Set window flags to ensure it stays on top
        self.setWindowFlags(
            Qt.Dialog | 
            Qt.WindowStaysOnTopHint |
            Qt.WindowTitleHint |
            Qt.WindowCloseButtonHint
        )
        
        # Main layout
        layout = QVBoxLayout()
        layout.setSpacing(20)
        
        # Header - Title
        title = QLabel("Configure Startup Options")
        title_font = QFont()
        title_font.setPointSize(16)
        title_font.setBold(True)
        title.setFont(title_font)
        title.setAlignment(Qt.AlignCenter)
        layout.addWidget(title)
        
        # Header - Subtitle
        subtitle = QLabel("Choose simulation backend and execution mode based on detected capabilities")
        subtitle.setAlignment(Qt.AlignCenter)
        subtitle.setStyleSheet("color: gray; margin-bottom: 10px;")
        layout.addWidget(subtitle)
        
        # Separator
        separator1 = QFrame()
        separator1.setFrameShape(QFrame.HLine)
        separator1.setFrameShadow(QFrame.Sunken)
        layout.addWidget(separator1)
        
        # Simulation Backend Selection
        backend_group = self._create_backend_group()
        layout.addWidget(backend_group)
        
        # Execution Mode Selection
        execution_group = self._create_execution_group()
        layout.addWidget(execution_group)
        
        # Advanced Options
        advanced_group = self._create_advanced_group()
        layout.addWidget(advanced_group)
        
        # Separator
        separator2 = QFrame()
        separator2.setFrameShape(QFrame.HLine)
        separator2.setFrameShadow(QFrame.Sunken)
        layout.addWidget(separator2)
        
        # Status info
        status_label = self._create_status_info()
        layout.addWidget(status_label)
        
        # Spacer
        layout.addStretch()
        
        # Buttons
        button_layout = QHBoxLayout()
        button_layout.addStretch()
        
        self.cancel_btn = QPushButton("Exit")
        self.cancel_btn.clicked.connect(self.reject)
        button_layout.addWidget(self.cancel_btn)
        
        self.start_btn = QPushButton("Start Application")
        self.start_btn.setDefault(True)
        self.start_btn.clicked.connect(self.accept_config)
        button_layout.addWidget(self.start_btn)
        
        layout.addLayout(button_layout)
        
        self.setLayout(layout)
    
    def _create_backend_group(self):
        """Create simulation backend selection group"""
        group = QGroupBox("Simulation Engine")
        layout = QVBoxLayout()
        
        # MATLAB checkbox (not radio button)
        self.use_matlab_checkbox = QCheckBox("Use MATLAB Spinach engine")
        self.use_matlab_checkbox.setChecked(True)
        self.use_matlab_checkbox.toggled.connect(self._on_matlab_toggled)
        
        matlab_desc = QLabel("    Full-featured quantum simulation using MATLAB Spinach toolbox")
        matlab_desc.setStyleSheet("color: gray; font-size: 10pt;")
        matlab_desc.setWordWrap(True)
        
        self.matlab_status = QLabel("")
        self.matlab_status.setStyleSheet("margin-left: 20px; font-size: 9pt;")
        
        layout.addWidget(self.use_matlab_checkbox)
        layout.addWidget(matlab_desc)
        layout.addWidget(self.matlab_status)
        layout.addSpacing(10)
        
        # Python fallback info (not a selectable option)
        python_info = QLabel("Fallback: Pure Python Simulation")
        python_info.setStyleSheet("font-weight: bold; color: #546E7A;")
        
        python_desc = QLabel("    Fast quantum simulation using NumPy/SciPy (automatically used if MATLAB is disabled or unavailable)")
        python_desc.setStyleSheet("color: gray; font-size: 10pt;")
        python_desc.setWordWrap(True)
        
        self.python_status = QLabel("")
        self.python_status.setStyleSheet("margin-left: 20px; font-size: 9pt;")
        
        layout.addWidget(python_info)
        layout.addWidget(python_desc)
        layout.addWidget(self.python_status)
        # --- MATLAB path input and configuration ---
        path_layout = QHBoxLayout()
        self.matlab_path_input = QLineEdit()
        self.matlab_path_input.setPlaceholderText(r"C:\Program Files\MATLAB\R20XXx")
        path_layout.addWidget(self.matlab_path_input)

        self.browse_matlab_btn = QPushButton("Browse...")
        self.browse_matlab_btn.clicked.connect(self._on_browse_matlab)
        path_layout.addWidget(self.browse_matlab_btn)

        layout.addLayout(path_layout)

        config_layout = QHBoxLayout()
        self.configure_matlab_btn = QPushButton("Configure MATLAB Engine")
        self.configure_matlab_btn.clicked.connect(self._on_configure_matlab)
        config_layout.addWidget(self.configure_matlab_btn)

        self.skip_matlab_btn = QPushButton("Skip MATLAB (use Python)")
        self.skip_matlab_btn.clicked.connect(self._on_skip_matlab)
        config_layout.addWidget(self.skip_matlab_btn)

        layout.addLayout(config_layout)

        # --- Embedded Spinach configuration ---
        spinach_layout = QHBoxLayout()
        self.spinach_checkbox = QCheckBox("Configure embedded Spinach package")
        self.spinach_checkbox.toggled.connect(self._on_spinach_toggled)
        spinach_layout.addWidget(self.spinach_checkbox)

        self.configure_spinach_btn = QPushButton("Configure Spinach")
        self.configure_spinach_btn.clicked.connect(self._on_configure_spinach)
        spinach_layout.addWidget(self.configure_spinach_btn)

        layout.addLayout(spinach_layout)
        
        group.setLayout(layout)
        return group
    
    def _create_execution_group(self):
        """Create execution mode selection group"""
        group = QGroupBox("Execution Mode")
        layout = QVBoxLayout()
        
        self.execution_group = QButtonGroup(self)
        
        # Local execution
        self.local_radio = QRadioButton("Local Execution")
        self.local_radio.setChecked(True)
        self.local_radio.toggled.connect(lambda: self._on_execution_changed('local'))
        self.execution_group.addButton(self.local_radio, 0)
        
        local_desc = QLabel("    Run simulations on this computer")
        local_desc.setStyleSheet("color: gray; font-size: 10pt;")
        
        self.local_status = QLabel("")
        self.local_status.setStyleSheet("margin-left: 20px; font-size: 9pt;")
        
        layout.addWidget(self.local_radio)
        layout.addWidget(local_desc)
        layout.addWidget(self.local_status)
        layout.addSpacing(10)
        
        # Workstation/Network execution
        self.workstation_radio = QRadioButton("Workstation (Network)")
        self.workstation_radio.toggled.connect(lambda: self._on_execution_changed('workstation'))
        self.execution_group.addButton(self.workstation_radio, 1)
        
        workstation_desc = QLabel("    Connect to remote workstation for high-performance computing")
        workstation_desc.setStyleSheet("color: gray; font-size: 10pt;")
        workstation_desc.setWordWrap(True)
        
        self.workstation_status = QLabel("")
        self.workstation_status.setStyleSheet("margin-left: 20px; font-size: 9pt;")
        
        layout.addWidget(self.workstation_radio)
        layout.addWidget(workstation_desc)
        layout.addWidget(self.workstation_status)
        
        group.setLayout(layout)
        return group
    
    def _create_advanced_group(self):
        """Create advanced options group"""
        group = QGroupBox("Advanced Options")
        layout = QVBoxLayout()
        
        # UI-only mode
        self.ui_only_checkbox = QCheckBox("UI-only mode (skip all simulations)")
        self.ui_only_checkbox.toggled.connect(self._on_ui_only_changed)
        ui_only_desc = QLabel("    Start interface without initializing any simulation backend")
        ui_only_desc.setStyleSheet("color: gray; font-size: 10pt; margin-left: 20px;")
        
        layout.addWidget(self.ui_only_checkbox)
        layout.addWidget(ui_only_desc)
        
        group.setLayout(layout)
        return group
    
    def _create_status_info(self):
        """Create status information label"""
        self.status_info = QLabel("")
        self.status_info.setWordWrap(True)
        self.status_info.setStyleSheet("padding: 10px; background-color: #f0f0f0; border-radius: 5px;")
        return self.status_info
    
    def update_availability(self):
        """Update UI based on initialization results"""
        matlab_available = self.init_results.get('matlab_available', False)
        python_available = self.init_results.get('python_simulation_available', True)
        network_available = self.init_results.get('network_available', False)
        
        # Update MATLAB status
        if matlab_available:
            self.matlab_status.setText("✓ MATLAB engine initialized and ready")
            self.matlab_status.setStyleSheet("margin-left: 20px; color: green; font-size: 9pt;")
            self.use_matlab_checkbox.setEnabled(True)
            self.use_matlab_checkbox.setChecked(True)
        else:
            self.matlab_status.setText("✗ MATLAB engine not available (will use Python fallback)")
            self.matlab_status.setStyleSheet("margin-left: 20px; color: red; font-size: 9pt;")
            self.use_matlab_checkbox.setEnabled(True)
            self.use_matlab_checkbox.setChecked(False)
            # Enable user to provide MATLAB path and attempt configuration even if not auto-detected
            self.matlab_path_input.setEnabled(True)
            self.browse_matlab_btn.setEnabled(True)
            self.configure_matlab_btn.setEnabled(True)
        
        # Update Python status (always shown as fallback)
        if python_available:
            if matlab_available and self.use_matlab_checkbox.isChecked():
                self.python_status.setText("ⓘ Available as fallback")
                self.python_status.setStyleSheet("margin-left: 20px; color: gray; font-size: 9pt;")
            else:
                self.python_status.setText("✓ Will be used for simulations")
                self.python_status.setStyleSheet("margin-left: 20px; color: green; font-size: 9pt;")
        else:
            self.python_status.setText("✗ Not available (TwoD_simulation module not found)")
            self.python_status.setStyleSheet("margin-left: 20px; color: orange; font-size: 9pt;")
        
        # Update Local status (always available)
        self.local_status.setText("✓ Always available")
        self.local_status.setStyleSheet("margin-left: 20px; color: green; font-size: 9pt;")
        
        # Update Workstation status
        if network_available:
            self.workstation_status.setText("✓ Network interface available")
            self.workstation_status.setStyleSheet("margin-left: 20px; color: green; font-size: 9pt;")
            self.workstation_radio.setEnabled(True)
        else:
            self.workstation_status.setText("✗ Network interface not configured")
            self.workstation_status.setStyleSheet("margin-left: 20px; color: orange; font-size: 9pt;")
            self.workstation_radio.setEnabled(False)
        
        # Update status info
        self._update_status_message()
    
    def _on_matlab_toggled(self, checked):
        """Handle MATLAB checkbox toggle"""
        self.selected_config['use_matlab'] = checked
        self.selected_config['skip_matlab'] = not checked
        
        # Update Python status display
        python_available = self.init_results.get('python_simulation_available', True)
        if python_available:
            if checked:
                self.python_status.setText("ⓘ Available as fallback")
                self.python_status.setStyleSheet("margin-left: 20px; color: gray; font-size: 9pt;")
            else:
                self.python_status.setText("✓ Will be used for simulations")
                self.python_status.setStyleSheet("margin-left: 20px; color: green; font-size: 9pt;")
        
        self._update_status_message()
    
    def _on_execution_changed(self, execution):
        """Handle execution mode change"""
        self.selected_config['execution'] = execution
        self._update_status_message()
    
    def _on_ui_only_changed(self, checked):
        """Handle UI-only mode change"""
        self.selected_config['ui_only_mode'] = checked
        
        # Disable backend and execution options if UI-only mode
        matlab_available = self.init_results.get('matlab_available', False)
        self.use_matlab_checkbox.setEnabled(not checked and matlab_available)
        self.local_radio.setEnabled(not checked)
        self.workstation_radio.setEnabled(not checked and self.init_results.get('network_available', False))
        
        self._update_status_message()
    
    def _update_status_message(self):
        """Update status information message"""
        if self.selected_config['ui_only_mode']:
            msg = "UI-only mode: Interface will start without any simulation capability."
            self.status_info.setStyleSheet("padding: 10px; background-color: #fff3cd; border-radius: 5px; color: #856404;")
        else:
            # Determine which engine will be used
            use_matlab = self.selected_config['use_matlab']
            matlab_available = self.init_results.get('matlab_available', False)
            
            if use_matlab and matlab_available:
                engine = "MATLAB Spinach engine"
            else:
                engine = "Pure Python simulation"
            
            execution = "locally" if self.selected_config['execution'] == 'local' else "on remote workstation"
            msg = f"Configuration: {engine} running {execution}"
            self.status_info.setStyleSheet("padding: 10px; background-color: #d1ecf1; border-radius: 5px; color: #0c5460;")
        
        self.status_info.setText(msg)
    
    def accept_config(self):
        """Accept configuration and emit signal"""
        # write current MATLAB path and flags
        self.selected_config['matlab_path'] = self.matlab_path_input.text() or None
        self.selected_config['configure_matlab_engine'] = getattr(self, 'configure_matlab_flag', False)
        self.selected_config['configure_embedded_spinach'] = getattr(self, 'configure_spinach_flag', False)
        self.selected_config['skip_matlab'] = getattr(self, 'skip_matlab_flag', False) or (not self.selected_config.get('use_matlab', True))
        self.config_selected.emit(self.selected_config)
        self.accept()

    # --- New handlers for MATLAB / Spinach configuration ---
    def _on_browse_matlab(self):
        path = QFileDialog.getExistingDirectory(self, "Select MATLAB Installation Directory", r"C:\Program Files\MATLAB")
        if path:
            self.matlab_path_input.setText(path)

    def _on_configure_matlab(self):
        # mark for configuration; actual installation should be handled by first-run setup
        self.configure_matlab_flag = True
        self.matlab_status.setText("⚙️ MATLAB engine configuration requested")
        self.matlab_status.setStyleSheet("margin-left: 20px; color: orange; font-size: 9pt;")

    def _on_skip_matlab(self):
        self.skip_matlab_flag = True
        self.use_matlab_checkbox.setChecked(False)
        self.use_matlab_checkbox.setEnabled(False)
        self.matlab_status.setText("⏭ MATLAB skipped by user; Python fallback will be used")
        self.matlab_status.setStyleSheet("margin-left: 20px; color: gray; font-size: 9pt;")

    def _on_spinach_toggled(self, checked):
        # Checkbox toggle only enables/disables the configure button
        # Actual flag is set when user clicks "Configure Spinach" button
        pass

    def _on_configure_spinach(self):
        self.configure_spinach_flag = True
        self.spinach_checkbox.setChecked(True)  # Also check the checkbox
        self.python_status.setText("⚙️ Embedded Spinach configuration requested")
        self.python_status.setStyleSheet("margin-left: 20px; color: orange; font-size: 9pt;")
    
    def get_config(self):
        """Get selected configuration"""
        return self.selected_config


# Standalone widget class for Qt Designer integration (future use)
class QWidget:
    pass


if __name__ == "__main__":
    import sys
    from PySide6.QtWidgets import QApplication
    
    app = QApplication(sys.argv)
    
    # Test with sample initialization results
    init_results = {
        'matlab_available': True,
        'python_simulation_available': True,
        'network_available': True,
        'file_integrity': True
    }
    
    dialog = StartupDialog(init_results)
    
    def on_config_selected(config):
        print(f"Selected configuration: {config}")
    
    dialog.config_selected.connect(on_config_selected)
    
    result = dialog.exec()
    print(f"Dialog result: {'Accepted' if result == QDialog.Accepted else 'Rejected'}")
    
    sys.exit()
