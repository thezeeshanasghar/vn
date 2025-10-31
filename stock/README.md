# stock

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



# Environment Configuration
PORT=3000
MONGODB_URI="mongodb+srv://abubakarrrmalik765_db_user:Ahohihi721%40@cluster0.nngb6k8.mongodb.net/vaccine_management?retryWrites=true&w=majority&appName=Cluster0"
NODE_ENV=development

# Add Flutter to PATH (Windows PowerShell)
$env:PATH += ";C:\src\flutter\bin"

# Run Admin System
cd vaccine_app
flutter run -d web-server --web-port 8081

# Run Doctor Portal
cd ../doctor_portal_app
flutter run -d web-server --web-port 8082

# Run Patient Panel
cd ../patient_panel
flutter run -d web-server --web-port 8083



  cd D:\Vaccine-Flutter-Node\MERN\vn\stock
  flutter pub get
  flutter run -d chrome --web-port 8080