# Certificat4

Application Flutter full-stack de démonstration connectée à une API publique et avec cache local pour le mode hors ligne.

## Fonctionnalités

- Authentification avec login/register/logout
- 3 écrans de données issues d’API : produits, posts, profil
- Repository pattern pour l’accès aux données
- Cache local via Hive
- Gestion du mode hors ligne avec fallback sur les données en cache
- Messages utilisateur en cas d’erreur réseau
- Intercepteur Dio pour l’injection du token JWT
- Tests unitaires sur la couche repository

## Stack technique

- Flutter
- Dio
- Hive + Hive Flutter
- Connectivity Plus
- DummyJSON API (publique)

## Architecture

Le projet suit une approche feature-first simple et lisible :

- core/ : gestion réseau, cache, erreurs, utilitaires
- features/auth/ : domaine + repository + écrans login/register
- features/products/ : entité produit + repository
- features/posts/ : entité post + repository
- features/dashboard/ : écran principal et onglets

## API utilisée

L’application utilise le service public DummyJSON :

- /auth/login
- /users/add
- /products
- /posts

## Configuration

1. Installer Flutter SDK
2. Lancer :

```bash
flutter pub get
flutter run
```

3. Pour les tests :

```bash
flutter test
```

## Notes

- Le token est stocké localement dans le cache Hive et injecté automatiquement via l’intercepteur Dio.
- Si le réseau est indisponible, l’application affiche les données déjà enregistrées localement.
- Le projet est conçu pour servir de base de certification ou de démonstration technique.
