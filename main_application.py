"""
Main Application Window - ZULF-NMR Suite

This is the main container that hosts different functional modules:
- NMR Simulation (Multi-system Spinach)
- Experimental Data Processing
- Future modules...

Each module is loaded as a separate tab for clean separation of concerns.
"""

import sys
from pathlib import Path

from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QApplication, QMainWindow, QTabWidget, QWidget,
    QVBoxLayout, QMessageBox, QLabel
)
from PySide6.QtGui import QAction

from src.utils.config import config
from src.utils.icon_manager import icon_manager


class MainApplication(QMainWindow):
    """
    Main application window with tab-based interface
    
    This container hosts multiple functional modules as separate tabs,
    providing a unified interface for the ZULF-NMR Suite.
    """
    
    def __init__(self, startup_config=None):
        """
        Initialize the main application window
        
        Args:
            startup_config: Configuration from startup dialog containing:
                - matlab_engine: Initialized MATLAB engine (if available)
                - backend: Selected backend (matlab or python)
                - mode: Execution mode (local or workstation)
        """
        super().__init__()
        
        self.startup_config = startup_config or {}
        self.matlab_engine = self.startup_config.get('matlab_engine')
        
        self._init_ui()
        self._create_menu_bar()
        self._load_modules()
        
    def _init_ui(self):
        """Initialize the main window UI"""
        self.setWindowTitle("ZULF-NMR Suite v0.1.0")
        self.setMinimumSize(1200, 800)
        
        # Set window icon
        app_icon = icon_manager.get_app_icon()
        if app_icon and not app_icon.isNull():
            self.setWindowIcon(app_icon)
        
        # Create central widget with tab container
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        
        layout = QVBoxLayout(central_widget)
        layout.setContentsMargins(0, 0, 0, 0)
        
        # Create tab widget
        self.tab_widget = QTabWidget()
        self.tab_widget.setTabPosition(QTabWidget.North)
        self.tab_widget.setMovable(False)
        layout.addWidget(self.tab_widget)
        
        # Create status bar
        self.statusBar().showMessage("Ready")
        
    def _create_menu_bar(self):
        """Create the application menu bar"""
        menubar = self.menuBar()
        
        # File menu
        file_menu = menubar.addMenu("&File")
        
        exit_action = QAction("E&xit", self)
        exit_action.setShortcut("Ctrl+Q")
        exit_action.setStatusTip("Exit application")
        exit_action.triggered.connect(self.close)
        file_menu.addAction(exit_action)
        
        # View menu
        view_menu = menubar.addMenu("&View")
        
        # Help menu
        help_menu = menubar.addMenu("&Help")
        
        about_action = QAction("&About", self)
        about_action.setStatusTip("About ZULF-NMR Suite")
        about_action.triggered.connect(self._show_about)
        help_menu.addAction(about_action)
        
    def _load_modules(self):
        """Load all functional modules as tabs"""
        
        # Tab 1: NMR Simulation Module
        try:
            from src.simulation.ui.simulation_window import MultiSystemSpinachUI
            
            simulation_widget = MultiSystemSpinachUI(
                matlab_engine=self.matlab_engine,
                parent=self
            )
            self.tab_widget.addTab(simulation_widget, "NMR Simulation")
            self.statusBar().showMessage("Simulation module loaded", 3000)
            
        except Exception as e:
            error_widget = QWidget()
            error_layout = QVBoxLayout(error_widget)
            error_label = QLabel(f"Failed to load simulation module:\n{str(e)}")
            error_label.setAlignment(Qt.AlignCenter)
            error_layout.addWidget(error_label)
            self.tab_widget.addTab(error_widget, "NMR Simulation (Error)")
            print(f"Error loading simulation module: {e}")
        
        # Tab 2: Data Processing Module (placeholder)
        processing_widget = QWidget()
        processing_layout = QVBoxLayout(processing_widget)
        placeholder_label = QLabel("Data Processing Module\n\n(To be implemented)")
        placeholder_label.setAlignment(Qt.AlignCenter)
        placeholder_label.setStyleSheet("font-size: 16px; color: gray;")
        processing_layout.addWidget(placeholder_label)
        self.tab_widget.addTab(processing_widget, "Data Processing")
        
    def _show_about(self):
        """Show about dialog"""
        about_text = (
            "<h2>ZULF-NMR Suite</h2>"
            "<p><b>Version:</b> 0.1.0 Beta</p>"
            "<p><b>Description:</b> Zero to Ultra-Low Field NMR Simulation and Analysis</p>"
            "<p>This software provides tools for NMR simulation and experimental data processing.</p>"
            "<p><b>Copyright:</b> 2024-2025</p>"
        )
        QMessageBox.about(self, "About ZULF-NMR Suite", about_text)
        
    def closeEvent(self, event):
        """Handle window close event"""
        reply = QMessageBox.question(
            self,
            "Confirm Exit",
            "Are you sure you want to exit?",
            QMessageBox.Yes | QMessageBox.No,
            QMessageBox.No
        )
        
        if reply == QMessageBox.Yes:
            # Clean up modules
            try:
                # Give simulation widget a chance to clean up
                for i in range(self.tab_widget.count()):
                    widget = self.tab_widget.widget(i)
                    if hasattr(widget, 'cleanup'):
                        widget.cleanup()
            except Exception as e:
                print(f"Error during cleanup: {e}")
            
            event.accept()
        else:
            event.ignore()


def main():
    """Standalone entry point for testing"""
    app = QApplication(sys.argv)
    
    # Set application metadata
    app.setOrganizationName("ZULF-NMR")
    app.setApplicationName("ZULF-NMR Suite")
    app.setApplicationVersion("0.1.0")
    
    # Create and show main window
    window = MainApplication()
    window.show()
    
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
