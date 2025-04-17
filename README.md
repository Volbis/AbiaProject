# 🗑️ Abia – La Poubelle Intelligente

**Abia** (qui signifie *poubelle* en Abouré) est un projet innovant de **gestion intelligente des déchets**, conçu pour faciliter le tri, la collecte et la sensibilisation écologique à l'aide de technologies embarquées.

Ce projet a pour objectif de créer une **poubelle connectée et autonome**, capable de détecter son taux de remplissage, de signaler lorsqu’elle est pleine, et de contribuer à un meilleur tri des déchets grâce à l’intelligence artificielle.

---

## ⚙️ Fonctionnalités principales

- 🔍 Détection automatique de remplissage via capteurs ultrasoniques  
- 🔒 Blocage du couvercle lorsque la poubelle est pleine  
- 🚦 Signal lumineux (LED) indiquant l’état de la poubelle :
  - 🟢 Verte : disponible
  - 🔴 Rouge : pleine
- 📡 Envoi de notifications (via serveur ou app) pour signaler les points à vider  
- 🗺️ Localisation GPS des poubelles sur une carte  
- 🧠 Tri intelligent selon le type de déchet *(en développement)*  
- 🌐 Interface Web pour la gestion et le suivi des poubelles  
- 🎥 Contenus visuels pour la sensibilisation (affiches, vidéos, site web)  

---

## 🧠 Technologies utilisées

- 🖥️ Raspberry Pi pour le contrôle central  
- 🔌 Capteurs ultrasoniques et LEDs pour la détection et le signal  
- ⚙️ Arduino & langage C pour la gestion des composants électroniques  
- 🐍 Python pour les scripts de communication (sockets, IA)  
- 🌐 HTML / CSS / JavaScript pour le site vitrine  
- 🎬 CapCut pour la création de contenu vidéo promotionnel  

---
## Structure du projet

lib/                     # Dossier principal contenant tout le code source
│
├── common/                  # Config et utilitaires (Utiliser dans tout le programme)
│   ├── constants/           # Constants de l'application (memes éléments partout)
│   ├── theme/               # Thème et styles de l'application
│   └── utils/               # Fonctions utilitaires (Fonctions de validations d'email....)
│
├── bin_data/                  # Couche données des poubelles & API....
│   ├── classes/             # Classes de données (User, Poubelle, etc.)
│   ├── data_poubelle/       # Gestion des données (Les donnée de la poubelle)
│   └── services/            # Servicesservices externes (API, notifications, etc.)
│
├── pages/                # Fonctionnalités principales (Les pages)
│   ├── auth/               # Authentification
│   │   ├── screens/        # Écrans (login, register)
│   │   ├── widgets/        # Widgets spécifiques à l'authentification
│   │   └── controllers/    # Logique métier
│   │
│   ├── carte_Poubelle_manage/            # Tableau de bord
│   │   ├── screens/        # Écrans (login, register)
│   │   ├── widgets/        # Widgets spécifiques à l'authentification
│   │   └── controllers/    # Logique métier
│   │ 
│   └── collecte/         # Gestion des collectes
│   │   ├── screens/        # Écrans (de collections de déchets)
│   │   ├── widgets/        # Widgets spécifiques à la collection
│   │   └── controllers/    # Logique métier
│   │
│   └── dashboard/        # Tableau de board
│   │   ├── screens/        # Écrans 
│   │   ├── widgets/        # Widgets spécifiques
│   │   └── controllers/    # Logique métier
│   │  
│   └── notifications/    # Tableau de board
│   │   ├── screens/        # Écrans 
│   │   ├── widgets/        # Widgets spécifiques
│   │   └── controllers/    # Logique métier
│   │  
├── Partagés/              # Composants partagés
│   ├── widgets/             # Widgets réutilisables
│
└── main.dart              # Point d'entrée de l'application

## 🎯 Objectifs du projet

- ♻️ Encourager une gestion plus écologique des déchets  
- 🤖 Promouvoir la technologie au service du développement durable  
- 🧒 Sensibiliser les citoyens à travers des outils modernes et attractifs  

---

*Abia, une innovation verte au cœur des villes.*
