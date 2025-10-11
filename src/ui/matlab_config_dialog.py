"""
MATLAB Configuration Dialog

Shown when MATLAB needs to be configured or has issues.
Guides user through:
- MATLAB path detection/selection
- MATLAB Engine installation
- Embedded Spinach configuration
"""

from PySide6.QtCore import Qt, Signal
from PySide6.QtWidgets import (
    QDialog, QVBoxLayout, QHBoxLayout, QLabel, QPushButton,
    QGroupBox, QLineEdit, QFileDialog, QTextEdit, QMessageBox
)
from PySide6.QtGui import QFont
from pathlib import Path

from src.utils.config import config
from src.utils.icon_manager import icon_manager


class MatlabConfigDialog(QDialog):
    """
    MATLAB configuration dialog for first-time setup or troubleshooting.
    
    Helps user configure MATLAB path and install MATLAB Engine.
    """
    
    config_selected = Signal(dict)
    
    def __init__(self, detected_matlab_path=None, matlab_version=None, parent=None):
        """
        Initialize MATLAB configuration dialog.
        
        Args:
            detected_matlab_path: Auto-detected MATLAB path (if any)
            matlab_version: Detected MATLAB version (if any)
        """
        super().__init__(parent)
        
        self.detected_path = detected_matlab_path
        self.matlab_version = matlab_version
        
        self.config = {
            'matlab_path': detected_matlab_path,
            'configure_matlab_engine': True,
            'configure_embedded_spinach': False,
        }
        
        self.setup_ui()
    
    def setup_ui(self):
        """Setup the dialog UI"""
        self.setWindowTitle(f"{config.app_name} - MATLAB Configuration")
        self.setWindowIcon(icon_manager.get_app_icon())
        self.setModal(True)
        self.setMinimumWidth(650)
        self.setMinimumHeight(450)
        
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
        title = QLabel("MATLAB Configuration Required")
        title_font = QFont()
        title_font.setPointSize(14)
        title_font.setBold(True)
        title.setFont(title_font)
        layout.addWidget(title)
        
        # Description
        desc = QLabel(
            "MATLAB Spinach engine is not configured. "
            "Please provide your MATLAB installation path to enable high-performance simulation."
        )
        desc.setWordWrap(True)
        desc.setStyleSheet("color: #6c757d; padding: 10px 0;")
        layout.addWidget(desc)
        
        # MATLAB Path Group
        path_group = QGroupBox("MATLAB Installation Path")
        path_layout = QVBoxLayout()
        
        path_input_layout = QHBoxLayout()
        self.matlab_path_input = QLineEdit()
        self.matlab_path_input.setPlaceholderText("e.g., F:/MATLAB or C:/Program Files/MATLAB/R2025a")
        
        if self.detected_path:
            self.matlab_path_input.setText(self.detected_path)
            if self.matlab_version:
                detected_label = QLabel(f"✓ Detected: MATLAB {self.matlab_version}")
                detected_label.setStyleSheet("color: #28a745; padding: 5px 0;")
                path_layout.addWidget(detected_label)
        
        browse_btn = QPushButton("Browse...")
        browse_btn.clicked.connect(self._on_browse_matlab)
        
        path_input_layout.addWidget(self.matlab_path_input)
        path_input_layout.addWidget(browse_btn)
        path_layout.addLayout(path_input_layout)
        
        # Path hint
        hint = QLabel("💡 MATLAB is typically installed in:\n"
                     "   • F:\\MATLAB (if on F: drive)\n"
                     "   • C:\\Program Files\\MATLAB\\R20XXx")
        hint.setStyleSheet("color: #6c757d; font-size: 11px; padding: 10px;")
        path_layout.addWidget(hint)
        
        path_group.setLayout(path_layout)
        layout.addWidget(path_group)
        
        # What will be configured
        config_group = QGroupBox("Configuration Steps")
        config_layout = QVBoxLayout()
        
        steps_text = """
The following will be configured:

1. MATLAB Engine for Python
   • Installed to embedded Python environment
   • Enables Python-MATLAB communication
   
2. Spinach Integration
   • Project's embedded Spinach (v2.9.2) will be used
   • Configured for parallel computing

⚠️ <b>Application restart required after configuration</b>
        """
        
        steps_label = QLabel(steps_text)
        steps_label.setWordWrap(True)
        steps_label.setStyleSheet("padding: 10px; background-color: #f8f9fa; border-radius: 5px;")
        config_layout.addWidget(steps_label)
        
        config_group.setLayout(config_layout)
        layout.addWidget(config_group)
        
        layout.addStretch()
        
        # Buttons
        button_layout = QHBoxLayout()
        button_layout.addStretch()
        
        cancel_btn = QPushButton("Cancel")
        cancel_btn.clicked.connect(self.reject)
        button_layout.addWidget(cancel_btn)
        
        skip_btn = QPushButton("Skip (Use Pure Python)")
        skip_btn.clicked.connect(self._on_skip)
        skip_btn.setStyleSheet("color: #6c757d;")
        button_layout.addWidget(skip_btn)
        
        configure_btn = QPushButton("Configure MATLAB")
        configure_btn.setDefault(True)
        configure_btn.clicked.connect(self._on_configure)
        configure_btn.setStyleSheet("""
            QPushButton {
                background-color: #28a745;
                color: white;
                padding: 8px 20px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: #218838;
            }
        """)
        button_layout.addWidget(configure_btn)
        
        layout.addLayout(button_layout)
        
        self.setLayout(layout)
    
    def _on_browse_matlab(self):
        """Browse for MATLAB installation directory"""
        path = QFileDialog.getExistingDirectory(
            self, 
            "Select MATLAB Installation Directory", 
            r"C:\Program Files\MATLAB"
        )
        if path:
            self.matlab_path_input.setText(path)
    
    def _on_skip(self):
        """User chose to skip MATLAB configuration"""
        self.config['configure_matlab_engine'] = False
        self.config['matlab_path'] = None
        self.reject()
    
    def _on_configure(self):
        """Validate and accept configuration"""
        matlab_path = self.matlab_path_input.text().strip()
        
        if not matlab_path:
            QMessageBox.warning(
                self,
                "MATLAB Path Required",
                "Please enter your MATLAB installation path first.\n\n"
                "Example: F:/MATLAB or C:/Program Files/MATLAB/R2024a"
            )
            return
        
        # Validate MATLAB path
        matlab_path_obj = Path(matlab_path)
        if not matlab_path_obj.exists():
            QMessageBox.warning(
                self,
                "Invalid Path",
                f"The path does not exist:\n{matlab_path}\n\n"
                "Please enter a valid MATLAB installation directory."
            )
            return
        
        # Save configuration
        self.config['matlab_path'] = matlab_path
        self.config['configure_matlab_engine'] = True
        
        self.config_selected.emit(self.config)
        self.accept()
    
    def get_config(self):
        """Get configuration"""
        return self.config
