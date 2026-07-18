# CLAUDE.md — Feuille de route + prompts pour le projet esensyaco

## Vision du projet
esensyaco est une application mobile destinée aux EHPAD, résidences seniors et structures médico-sociales pour améliorer la communication entre résidents, familles, équipes internes et prestataires externes, tout en ajoutant des services réservables, des notifications, un agenda, un espace solidaire et un cadre de suivi transparent [1].

Le périmètre fonctionnel identifié dans le document source couvre notamment la messagerie, le partage de photos, l’agenda, les réservations de prestations, les paiements, les notifications, les tableaux de bord, les profils multi-rôles et des extensions possibles comme le journal de vie, les appels vidéo, le module solidarité et des fonctions administratives [1].

## Orientation technique recommandée
Pour ce projet, une approche de développement maîtrisée et évolutive est plus cohérente qu’une dépendance complète à un outil visuel, surtout si l’objectif est de construire une base solide sur la durée [2][3].

L’orientation conseillée est donc :
- Front mobile : Flutter.
- Backend : Firebase au démarrage.
- Paiement : Stripe.
- Notifications : Firebase Cloud Messaging.
- Stockage média : Firebase Storage.
- Administration future : dashboard web séparé si nécessaire [1][2].

## Décision produit
Le MVP ne doit pas chercher à tout faire dès le départ. Le document source recommande une première version centrée sur quelques profils et fonctions clés : connexion, profils, messagerie, photos, agenda, réservation de services et notifications [1].

Le bon cadrage consiste à lancer vite un noyau fonctionnel simple, testable avec quelques établissements pilotes, puis enrichir en fonction des retours terrain [1].

## Feuille de route

## Phase 0 — Cadrage
Objectif : verrouiller le périmètre avant le développement.

Livrables :
- Positionnement du projet.
- Liste des utilisateurs cibles : résident, famille, professionnel, prestataire, admin [1].
- Liste des fonctionnalités MVP.
- Parcours utilisateurs.
- Règles métier essentielles.
- Architecture de données initiale.

Checklist :
- Définir les rôles exacts.
- Définir ce que chaque rôle peut voir et faire.
- Définir les écrans obligatoires du MVP.
- Définir les données sensibles et les règles de sécurité.
- Définir les métriques de test pilote.

## Phase 1 — Architecture
Objectif : poser une base technique propre.

Modules à préparer :
- Authentification.
- Gestion des rôles.
- Structure de navigation.
- Schéma Firestore.
- Upload fichiers et médias.
- Notifications push.
- Journalisation minimale des actions importantes [1].

Collections de départ inspirées du projet :
- `users`
- `residents`
- `families`
- `facilities`
- `staff`
- `providers`
- `chats`
- `messages`
- `services`
- `bookings`
- `notifications`
- `photos` [1]

## Phase 2 — MVP mobile
Objectif : sortir une première app exploitable.

Écrans prioritaires :
1. Splash.
2. Connexion.
3. Inscription.
4. Accueil.
5. Profil.
6. Liste des conversations.
7. Chat.
8. Agenda.
9. Liste des services.
10. Détail service.
11. Réservation.
12. Notifications [1].

Fonctionnalités MVP :
- Connexion sécurisée.
- Création de compte.
- Routage selon rôle.
- Messagerie simple.
- Publication de photos.
- Agenda partagé basique.
- Réservation de prestations.
- Confirmation et suivi de statut.
- Notifications [1].

## Phase 3 — Pilote terrain
Objectif : tester dans 1 à 3 établissements.

À valider :
- Simplicité d’usage.
- Temps de prise en main.
- Fiabilité de la messagerie.
- Compréhension des écrans par les familles.
- Fluidité du parcours réservation.
- Pertinence des notifications [1].

Indicateurs :
- Nombre d’utilisateurs actifs.
- Nombre de réservations effectuées.
- Nombre de messages échangés.
- Taux d’erreur.
- Feedback qualitatif des familles et équipes.

## Phase 4 — V2
Objectif : ajouter ce qui crée de la différenciation.

Modules possibles après validation MVP :
- Paiement Stripe.
- Journal de vie.
- Appels vidéo.
- Espace solidarité / dons / ventes / location de matériel.
- Tableau de bord établissement.
- Gestion prestataires.
- Satisfaction utilisateur.
- Module tutelle / protection juridique si confirmé [1].

## Règles produit
- Ne jamais développer les modules complexes avant validation du noyau.
- Un écran doit répondre à un besoin métier clair.
- Chaque rôle doit avoir une navigation simple.
- La sécurité et la confidentialité doivent être prévues dès le départ [1].
- Les fonctions sensibles doivent être journalisées.

## Stack conseillée

| Couche | Choix recommandé | Pourquoi |
|---|---|---|
| App mobile | Flutter | Bon compromis entre performance, UI cohérente et maintenance [2] |
| Backend | Firebase | Rapide à lancer pour auth, base, stockage et notifications [1] |
| Paiement | Stripe | Adapté aux réservations et paiements de services [1] |
| Push | FCM | Intégration naturelle avec Firebase [1] |
| Admin web | Next.js ou React plus tard | À ajouter seulement après validation MVP |

## Arborescence projet suggérée

```txt
esensyaco/
  mobile/
    lib/
      core/
      features/
        auth/
        home/
        profile/
        chat/
        agenda/
        services/
        booking/
        notifications/
      shared/
  backend/
    firestore-rules/
    cloud-functions/
  docs/
    product/
    ux/
    architecture/
```

## Ordre de développement recommandé
1. Auth.
2. Rôles utilisateurs.
3. Layout global.
4. Profils.
5. Conversations.
6. Chat.
7. Agenda.
8. Services.
9. Réservations.
10. Notifications.
11. Photos.
12. Tests pilote [1].

## Prompts Claude Code

### Prompt 1 — cadrage global
```md
Tu es un lead product + lead developer.
Aide-moi à structurer le projet mobile esensyaco.
Contexte : application pour EHPAD, familles, résidents, personnel et prestataires.
Objectif MVP : connexion, profils, messagerie, photos, agenda, réservation de services, notifications.

Ta mission :
1. reformuler le projet proprement,
2. lister les rôles utilisateurs,
3. définir les fonctionnalités MVP,
4. proposer une architecture Flutter modulaire,
5. proposer une structure Firebase,
6. identifier les risques techniques et produit,
7. me sortir un plan de développement par sprint.

Contraintes :
- réponse très structurée,
- en français,
- orientée production,
- sans blabla,
- avec tableaux quand utile.
```

### Prompt 2 — architecture Flutter
```md
Agis comme un architecte Flutter senior.
Crée l’architecture d’une application Flutter propre, scalable et maintenable pour esensyaco.

Contexte :
- application mobile multi-rôles,
- rôles : résident, famille, staff, prestataire, admin,
- backend : Firebase,
- modules MVP : auth, profils, chat, agenda, services, réservations, notifications.

Je veux :
- arborescence complète du projet,
- séparation feature-first,
- gestion d’état recommandée,
- organisation data/domain/presentation,
- conventions de nommage,
- stratégie de routing,
- stratégie de gestion des rôles,
- stratégie de sécurité côté client.

Donne un résultat directement exploitable dans un vrai projet.
```

### Prompt 3 — Firestore
```md
Agis comme un expert Firebase / Firestore.
Conçois le schéma Firestore de esensyaco pour un MVP mobile.

Je veux :
- collections,
- sous-collections si nécessaires,
- champs recommandés,
- relations entre entités,
- indexes probables,
- règles de sécurité Firestore,
- bonnes pratiques pour éviter les lectures inutiles,
- gestion des rôles et permissions.

Contexte métier :
application pour EHPAD avec familles, résidents, staff, prestataires, réservations, messagerie, photos et notifications.

Présente la réponse sous forme de tableau + règles prêtes à adapter.
```

### Prompt 4 — PRD MVP
```md
Agis comme un product manager senior.
Rédige un PRD complet pour le MVP de esensyaco.

Le document doit inclure :
- vision produit,
- problème marché,
- utilisateurs cibles,
- user stories,
- fonctionnalités incluses,
- exclusions du MVP,
- parcours utilisateurs,
- critères d’acceptation,
- métriques de succès,
- risques,
- roadmap V1 vers V2.

Le ton doit être professionnel, clair, concret, prêt à partager à un développeur ou partenaire.
```

### Prompt 5 — génération d’écrans
```md
Agis comme un UX designer mobile senior.
Conçois la liste complète des écrans MVP de esensyaco avec pour chaque écran :
- objectif,
- utilisateur concerné,
- composants UI,
- actions principales,
- états vides,
- erreurs,
- permissions,
- microcopies utiles.

Contexte : app mobile EHPAD, familles, résidents, staff et prestataires.
Je veux un rendu directement exploitable pour passer en design puis en développement Flutter.
```

### Prompt 6 — génération de code écran par écran
```md
Agis comme un développeur Flutter senior.
Nous allons construire esensyaco écran par écran.
À chaque réponse :
- génère le code complet,
- indique les fichiers à créer,
- respecte une architecture feature-first,
- utilise des composants réutilisables,
- ajoute seulement le strict nécessaire,
- évite le pseudo-code,
- code prêt à coller.

Commence par : écran de connexion avec Firebase Auth, validation des champs, gestion d’erreur et redirection selon rôle utilisateur.
```

### Prompt 7 — backlog sprint
```md
Agis comme un CTO produit.
Transforme le MVP de esensyaco en backlog agile priorisé.

Je veux :
- epics,
- user stories,
- priorités MoSCoW,
- dépendances,
- estimation simple par complexité,
- ordre de livraison recommandé.

Format attendu : tableau clair + proposition de sprints sur 6 semaines.
```

### Prompt 8 — audit produit
```md
Agis comme un consultant startup SaaS/mobile.
Analyse esensyaco comme si tu préparais un lancement pilote dans des EHPAD.

Évalue :
- clarté de la proposition de valeur,
- risques marché,
- risques adoption,
- risques techniques,
- risques réglementaires,
- fonctionnalités à retirer du MVP,
- fonctionnalités à garder absolument,
- recommandations pour réussir les 3 premiers pilotes.

Réponse directe, critique, honnête, orientée exécution.
```

## Mode d’utilisation recommandé avec Claude Code
- Étape 1 : lancer le prompt cadrage global.
- Étape 2 : figer l’architecture Flutter.
- Étape 3 : figer le schéma Firestore.
- Étape 4 : générer le PRD MVP.
- Étape 5 : générer la liste des écrans.
- Étape 6 : construire module par module.
- Étape 7 : créer le backlog et les sprints.
- Étape 8 : faire auditer régulièrement le périmètre pour éviter le sur-développement.

## Recommandation finale
Tu n’as pas besoin de FlutterFlow pour lancer ce projet. Une base propre avec Flutter, Firebase et un usage intelligent de Claude Code est cohérente avec la complexité du produit, le besoin de contrôle et l’évolution long terme du projet [2][3].





// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyDJOKdOElpBMYjVgX9yLl1HLc9kc0r5hoM",
  authDomain: "essencia-et-co.firebaseapp.com",
  projectId: "essencia-et-co",
  storageBucket: "essencia-et-co.firebasestorage.app",
  messagingSenderId: "70499913861",
  appId: "1:70499913861:web:6bc31541a50e08614399ec",
  measurementId: "G-NVNV3QBLM3"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);


https://github.com/weblinecreation88-art/ESSENCIA-ET-CO

