# BrightFret

Application mobile Flutter de suivi de colis pour les clients finaux de transitaires (Chine → Cameroun/Afrique).

**Plateformes :** iOS 14+ · Android API 24+ · Web (dev/test uniquement)

---

## Présentation

BrightFret permet aux clients d'un transitaire de :

- Suivre leurs colis en temps réel via code de suivi ou QR
- Consulter la timeline des événements de transit et les documents
- Echanger des messages avec le transitaire
- Déposer et suivre des réclamations (perte, dommage, retard)
- Recevoir des notifications sur les évolutions de leurs envois

L'application se connecte au backend Odoo `bw_freight_management` via une API REST publique/authentifiée.

---

## Architecture

| Couche | Choix |
|--------|-------|
| State management | Riverpod (`riverpod_annotation` + codegen) |
| Navigation | go_router — toutes les routes dans `app_router.dart` |
| HTTP | Dio — 4 intercepteurs : Auth, Error→`ApiException`, LoggingDebugOnly, LanguageInterceptor |
| Cache local | Hive (`hive_flutter`) — 6 boxes typées |
| Scanner QR | `mobile_scanner` — caméra live + galerie |
| Deep links | Schéma custom `brightfret://track/{FULL_CODE}` via `app_links` |
| Notifications push | Aucune — SMS Twilio côté serveur + polling delta in-app |
| Messagerie | Polling HTTP toutes les 30s (`Timer.periodic`) |
| Connectivité | `connectivity_plus` → `ConnectivityNotifier` (keepAlive) |
| Police | Nunito via `google_fonts` |
| Localisation | ARB/intl — FR + EN, langue persistée en Hive |

---

## Structure du projet

```
lib/
├── main.dart                    # Init Hive + ForwarderResolver + DeepLinkHandler
├── core/
│   ├── constants/               # couleurs, enums, styles, thème
│   ├── deep_links/              # DeepLinkHandler (cold-start + foreground)
│   ├── http/                    # DioClient, ApiException (sealed), dio_provider
│   ├── models/                  # modèles Hive typés (AuthToken, CachedShipment…)
│   ├── providers/               # auth, connectivité, locale, onboarding, updates
│   ├── router/                  # app_router.dart + router_notifier.dart (redirects)
│   ├── storage/                 # HiveService (6 boxes), TokenStorage
│   └── utils/                   # ForwarderResolver, TrackingCodeParser
├── features/
│   ├── auth/                    # S07 — vérification téléphone (PIN 4 chiffres)
│   ├── claims/                  # S18 — formulaire, statut, liste des réclamations
│   ├── messaging/               # S11 — messagerie async (polling 30s)
│   ├── onboarding/              # S02 — 3 slides
│   ├── settings/                # S14 — langue, cache, version
│   ├── shipment/                # S08–S10 — détail, documents, visionneuse
│   ├── tracking/                # S03–S06, S12, S15–S16 — suivi public, scanner, mes colis
│   └── updates/                 # S13 — journal des mises à jour
├── l10n/
│   ├── app_fr.arb               # Français (template, ~155 clés)
│   └── app_en.arb               # Anglais
└── shared/widgets/              # composants réutilisables (BfAppBar, BfStatusBadge…)
assets/
├── data/forwarders.json         # registre des transitaires (prefix → url + database)
└── images/logo_brightfret.png
```

---

## Prérequis

- Flutter SDK ≥ 3.6.0
- Dart SDK ≥ 3.6.0
- JDK complet pour le build Android (voir ci-dessous)

### Configuration JDK Android

```bash
# Si flutter build apk échoue avec "jlink does not exist" :
flutter config --jdk-dir /snap/android-studio/current/jbr
# Ne pas utiliser /usr/lib/jvm/java-21-openjdk-amd64 (JRE uniquement)
```

---

## Installation et lancement

```bash
# Dépendances
flutter pub get

# Génération de code (Riverpod .g.dart + adaptateurs Hive)
# À relancer après toute modification de provider ou modèle
dart run build_runner build --delete-conflicting-outputs

# Régénération des traductions (après modification d'un fichier .arb)
flutter gen-l10n

# Serveur de développement web
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0

# Analyse statique (doit être à zéro avant tout commit)
flutter analyze
```

---

## Build

```bash
# APK debug (développement / émulateur)
flutter build apk --debug

# APK release (distribution testeurs — signé avec la clé debug)
flutter build apk --release
# Sortie → build/app/outputs/flutter-apk/app-release.apk

# iOS debug
flutter build ios --debug
```

---

## Configuration multi-transitaires

Le fichier `assets/data/forwarders.json` mappe les préfixes de codes de suivi vers les instances Odoo :

```json
{
  "BWF": {
    "name": "BrightWill Freight",
    "url": "http://localhost:8070",
    "database": "odoo"
  }
}
```

`ForwarderResolver` est chargé dans `main()` avant `runApp()` pour garantir la disponibilité du registre quelle que soit la page d'entrée (deep link, URL directe web).

---

## Deep links

Schéma custom : `brightfret://track/{CODE_COMPLET}`

Exemples :
```
brightfret://track/BWF-2026-A7X9K2
```

- **Cold-start** : `getInitialLink()` dans `DeepLinkHandler`
- **Foreground** : stream `uriLinkStream`
- Redirige vers la timeline publique (S06) ou l'écran "transitaire inconnu" (S15)

---

## API backend

| Endpoint | Auth | Description |
|----------|------|-------------|
| `GET /api/track/{suffix}` | Aucune | Suivi public |
| `POST /api/track/{suffix}/verify` | Aucune | Vérification téléphone → token 24h |
| `GET /api/forwarder/info` | Aucune | Nom, logo, couleur primaire |
| `GET /api/shipment/{suffix}` | Token | Détail complet |
| `GET /api/shipment/{suffix}/documents` | Token | Pièces jointes |
| `GET /api/shipment/{suffix}/messages` | Token | Messages chatter |
| `POST /api/shipment/{suffix}/message` | Token | Envoyer un message |
| `POST /api/shipment/{suffix}/claim` | Token | Déposer une réclamation |
| `GET /api/shipment/{suffix}/claim` | Token | Statut du dernier claim |
| `GET /api/shipment/{suffix}/claims` | Token | Liste de tous les claims |

Le module Odoo backend se trouve dans :
`/home/madoh/Desktop/devprojects/brightwill-core/vendor/odoo/custom_addons/bw_freight_management/`

---

## Boxes Hive

| Box | Clé | Contenu | TTL |
|-----|-----|---------|-----|
| `shipments` | `{instance}:{suffix}` | `CachedShipment` | 5 min |
| `forwarder_info` | `{instance}` | `CachedForwarderInfo` | 7 jours |
| `my_shipments` | code de suivi complet | `SavedShipment` | Permanent |
| `tokens` | `{instance}:{suffix}` | `AuthToken` | 24h |
| `updates` | int auto-incrémenté | `AppUpdate` | 30 jours |
| `prefs` | divers | langue, onboarding, historique | Permanent |

---

## Branding

- Couleur primaire : `#002868` (bleu BrightFret) · Accent : `#BF0A30` (rouge)
- Police : Nunito · Material 3 (`useMaterial3: true`)
- La couleur primaire est surchargeable par transitaire via `app_primary_color` (Odoo Settings)

---

## Checklist déploiement production

- [ ] Retirer les routes debug (`/test/inject`, `/test/seed-updates`) de `app_router.dart`
- [ ] Tester les deep links `brightfret://track/...` sur device physique
- [ ] Vérifier `app_primary_color` configuré dans Odoo si couleur custom
- [ ] Clés Twilio configurées côté Odoo (SMS notifications)
- [ ] Backend Odoo derrière HTTPS (requis pour `getUserMedia` caméra en prod)
