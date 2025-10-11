"""
Startup Selection Dialog

Simple dialog shown after successful initialization to let user choose:
- MATLAB Spinach or Pure Python simulation
- Local or Workstation execution mode
"""

from PySide6.QtCore import Qt, Signal
from PySide6.QtWidgets import (
    QDialog, QVBoxLayout, QHBoxLayout, QLabel, QPushButton,
    QGroupBox, QRadioButton, QButtonGroup
)
from PySide6.QtGui import QFont

from src.utils.config import config
from src.utils.icon_manager import icon_manager


class StartupSelectionDialog(QDialog):
    """
    Simple startup selection dialog for normal launches.
    
    Shown when MATLAB is working fine - just lets user choose mode.
    """
    
    config_selected = Signal(dict)
    
    def __init__(self, matlab_available=True, parent=None):
        """
        Initialize selection dialog.
        
        Args:
            matlab_available: Whether MATLAB engine is available
        """
        super().__init__(parent)
        
        self.matlab_available = matlab_available
        self.selected_config = {
            'use_matlab': matlab_available,  # Default to MATLAB if available
            'execution': 'local',
            'ui_only_mode': False,
            'matlab_path': None,
            'configure_matlab_engine': False,
            'configure_embedded_spinach': False,
            'skip_matlab': False,
        }
        
        self.setup_ui()
    
    def setup_ui(self):
        """Setup the dialog UI"""
        self.setWindowTitle(f"{config.app_name} - Select Execution Mode")
        self.setWindowIcon(icon_manager.get_app_icon())
        self.setModal(True)
        self.setFixedWidth(500)
        
        self.setWindowFlags(
            Qt.Dialog | 
            Qt.WindowStaysOnTopHint |
            Qt.WindowTitleHint |
            Qt.WindowCloseButtonHint
        )
        
        layout = QVBoxLayout()
        layout.setSpacing(20)
        layout.setContentsMargins(30, 30, 30, 30)
        
        # Title
        title = QLabel("Select Execution Mode")
        title_font = QFont()
        title_font.setPointSize(14)
        title_font.setBold(True)
        title.setFont(title_font)
        layout.addWidget(title)
        
        # Simulation Backend Group
        backend_group = QGroupBox("Simulation Backend")
        backend_layout = QVBoxLayout()
        
        self.matlab_radio = QRadioButton("MATLAB Spinach Engine")
        self.matlab_radio.setChecked(self.matlab_available)
        self.matlab_radio.setEnabled(self.matlab_available)
        
        self.python_radio = QRadioButton("Pure Python Simulation")
        self.python_radio.setChecked(not self.matlab_available)
        
        self.backend_group = QButtonGroup()
        self.backend_group.addButton(self.matlab_radio, 0)
        self.backend_group.addButton(self.python_radio, 1)
        
        backend_layout.addWidget(self.matlab_radio)
        if self.matlab_available:
            matlab_info = QLabel("  ✓ High-performance parallel computing")
            matlab_info.setStyleSheet("color: #28a745; margin-left: 20px;")
            backend_layout.addWidget(matlab_info)
        else:
            matlab_warn = QLabel("  ⚠ MATLAB not available")
            matlab_warn.setStyleSheet("color: #dc3545; margin-left: 20px;")
            backend_layout.addWidget(matlab_warn)
        
        backend_layout.addSpacing(10)
        backend_layout.addWidget(self.python_radio)
        python_info = QLabel("  • NumPy-based simulation (slower)")
        python_info.setStyleSheet("color: #6c757d; margin-left: 20px;")
        backend_layout.addWidget(python_info)
        
        backend_group.setLayout(backend_layout)
        layout.addWidget(backend_group)
        
        # Execution Mode Group
        exec_group = QGroupBox("Execution Location")
        exec_layout = QVBoxLayout()
        
        self.local_radio = QRadioButton("Run Locally")
        self.local_radio.setChecked(True)
        
        self.workstation_radio = QRadioButton("Remote Workstation")
        self.workstation_radio.setEnabled(False)  # Not implemented yet
        
        self.exec_group = QButtonGroup()
        self.exec_group.addButton(self.local_radio, 0)
        self.exec_group.addButton(self.workstation_radio, 1)
        
        exec_layout.addWidget(self.local_radio)
        exec_layout.addWidget(self.workstation_radio)
        
        exec_group.setLayout(exec_layout)
        layout.addWidget(exec_group)
        
        # Buttons
        button_layout = QHBoxLayout()
        button_layout.addStretch()
        
        if not self.matlab_available:
            config_btn = QPushButton("Configure MATLAB...")
            config_btn.clicked.connect(self._on_configure_matlab)
            button_layout.addWidget(config_btn)
        
        cancel_btn = QPushButton("Exit")
        cancel_btn.clicked.connect(self.reject)
        button_layout.addWidget(cancel_btn)
        
        start_btn = QPushButton("Start Application")
        start_btn.setDefault(True)
        start_btn.clicked.connect(self.accept_config)
        start_btn.setStyleSheet("""
            QPushButton {
                background-color: #007bff;
                color: white;
                padding: 8px 20px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: #0056b3;
            }
        """)
        button_layout.addWidget(start_btn)
        
        layout.addLayout(button_layout)
        
        self.setLayout(layout)
    
    def accept_config(self):
        """Accept configuration and emit signal"""
        self.selected_config['use_matlab'] = self.matlab_radio.isChecked()
        self.selected_config['execution'] = 'local' if self.local_radio.isChecked() else 'workstation'
        
        self.config_selected.emit(self.selected_config)
        self.accept()
    
    def _on_configure_matlab(self):
        """Open MATLAB configuration dialog"""
        from .matlab_config_dialog import MatlabConfigDialog
        
        config_dialog = MatlabConfigDialog(parent=self)
        if config_dialog.exec() == QDialog.Accepted:
            config = config_dialog.get_config()
            # Merge configuration
            self.selected_config.update(config)
            # Mark that we need MATLAB configuration
            self.selected_config['configure_matlab_engine'] = True
            # Close this dialog and proceed with configuration
            self.accept_config()
    
    def get_config(self):
        """Get selected configuration"""
        return self.selected_config
