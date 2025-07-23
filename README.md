# Application de planification de voyage intelligente avec IA et gestion budgétaire - Version Mobile

# Travelin Mobile 🏖️📱

**Application mobile intelligente de planification de voyages en Tunisie**

Travelin est une application web et mobile innovante qui utilise l'intelligence artificielle pour proposer des itinéraires de voyage personnalisés en Tunisie. Grâce à des algorithmes de machine learning avancés, elle analyse les préférences des utilisateurs et recommande les meilleurs hôtels et activités selon leurs critères.

## 🚀 Fonctionnalités principales

🤖 Moteur de recommandation IA : Génération d'itinéraires personnalisés avec machine learning (RandomForest, TF-IDF)
🤖 Un plan de voyage detaillée :Génération d'un plan de voyage détaillé à l'aide de Groq LLM.
📱 Interface responsive : Compatible web et mobile (Vue.js + flutter)
🏨 Recherche d'hôtels : Plus de 100 villes tunisiennes, filtres avancés
🎯 Personnalisation : Budget, centres d'intérêt, type de séjour, période
👤 Gestion des comptes : Inscription, connexion, profil utilisateur
📊 Administration : Dashboard admin, gestion des réservations
📝 Blog & FAQ : Contenu informatif et support utilisateur

## 🛠️ Technologies utilisées

### Mobile
- **Flutter** (Framework cross-platform)
- **Dart** (Langage de programmation)
- **Material Design** (UI/UX)

### Backend & IA
- **Laravel API** (Backend RESTful)
- **Machine Learning** : Recommandations personnalisées
- **FastAPI** (Microservice IA)
- **Base de données** : MySQL

### Services
- **Google Sign-In** (Authentification)
- **HTTP Client** (Communication API)
- **SharedPreferences** (Stockage local)
- **Image Picker** (Gestion photos)

## 📦 Installation

### Prérequis
- Flutter SDK 3.0+
- Dart SDK
- Android Studio / VS Code
- Émulateur Android ou appareil physique

### Installation mobile
```bash
# Cloner le repository
git clone https://github.com/sadoksoltan/Application-de-planification-de-voyage-intelligente-avec-IA-et-gestion-budg-taire-version-mobile.git

# Entrer dans le dossier
cd Application-de-planification-de-voyage-intelligente-avec-IA-et-gestion-budg-taire-version-mobile

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

### Configuration backend
```bash
# Backend Laravel
cd backend/Travel
php artisan serve

# Serveur IA
cd backend
uvicorn main:app --reload --host 0.0.0.0 --port 8001
```

## 🔧 Configuration

### Variables d'environnement
```dart
final String baseUrl = 'http://10.0.2.2:8000'; // Pour émulateur Android
```
👨‍💻 Auteur
Soltan sadok - Développeur Full Stack & IA

Démonstration - lien Drive: demander l'accès, je vous l'attribuerai dès que possible(https://drive.google.com/file/d/18oof5k-RZoNT5fTpdzSSNFjNSnmXFVLP/view?usp=drive_link)].
⭐ **N'hésitez pas à donner une étoile au projet si vous l'appréciez !**
