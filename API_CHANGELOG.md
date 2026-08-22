# API Changelog — bw_freight_management vs BrightFret Flutter

**Date de rédaction :** 2026-08-22  
**Sources :** `controllers/tracking.py`, `controllers/shipment.py`, `models/freight_shipment.py`, `models/freight_claim.py`, `models/freight_tracking_token.py`  
**Rapport de test :** `TEST_REPORT_V2.md` (bureau) — campagne de scellement 2026-08-22, tous niveaux ✅  
**Module analysé :** `/home/madoh/Desktop/devprojects/brightwill-core/vendor/odoo/custom_addons/bw_freight_management/`  
**App analysée :** ce repo (BrightFret Flutter)

---

## Résumé exécutif

Cinq changements côté backend méritent attention.  
Deux nécessitent des modifications dans l'app Flutter (priorités 🔴 et 🟠).  
Trois sont des informations à connaître sans code à changer (🟡 / ✅).

| Priorité | Changement | Action Flutter |
|----------|-----------|----------------|
| 🟠 | `FullShipment` ne parse pas `terms_acceptance_required` / `terms_acceptance_url` | Bouton inline dans S11 |
| 🟠 | `ForwarderInfo` ne parse pas `can_create_claims` / `terms_enabled` | Masquer bouton claim sur Starter |
| 🟠 | Claim créée → état `under_review` immédiat | Corriger `_detectClaimUpdate` |
| ✅ | Nouveau champ `client_phone` dans le payload | Aucune action — pas d'usage côté client |
| ✅ | Cache token Hive + skip `/verify` si valide | Déjà correctement implémenté |
| ✅ | Documents inline (`data`/string `id`) | Déjà géré |
| ✅ | Champ `cargo` dans detail shipment | Déjà géré |
| ✅ | `paymentStatus` 3 états | Déjà géré |
| ✅ | `claims` list endpoint | Déjà géré |

---

## 1. 🟠 CGU — `FullShipment` ne parse pas `terms_acceptance_required` ni `terms_acceptance_url`

### Ce qui est dans le payload actuel (confirmé sur BWF-2026-YWHU7X)

`GET /api/shipment/{suffix}` retourne déjà deux champs CGU :

```json
{
  "terms_acceptance_required": false,
  "terms_acceptance_url": "http://localhost:8070/terms/YWHU7X"
}
```

`terms_acceptance_required` est un booléen calculé côté Odoo qui vaut :
```
terms_enabled  AND  NOT terms_accepted  AND  state != 'cancelled'
```
C'est le **seul champ dont Flutter a besoin** pour décider d'afficher le bouton.
Il couvre automatiquement tous les cas : feature désactivée, déjà acceptée, colis annulé.

L'endpoint d'acceptation est déjà disponible :
```
POST /api/shipment/{suffix}/terms
Authorization: Bearer {token}   ← token déjà en mémoire (S11 est post-vérif)
→ 200  {"status": "accepted"}
→ 403  plan < Enterprise
```

### Flow retenu — bouton inline dans S11 (messagerie)

Zéro nouvel écran. Zéro sortie de l'app. L'utilisateur qui lit S11 a déjà son token.

1. Quand `terms_acceptance_required == true` : afficher un bandeau d'action **au-dessus**
   de la liste des messages dans S11 (ou en premier élément de la liste) :
   > "Le transitaire vous demande d'accepter les conditions d'utilisation."
   > `[Accepter]`

2. Tap → `POST /api/shipment/{suffix}/terms` (Bearer token déjà disponible).

3. Succès → `ref.invalidate(fullShipmentProvider)` → `terms_acceptance_required`
   passe à `false` → le bandeau disparaît.

4. Si `terms_acceptance_url` doit rester accessible (lecture des CGU avant d'accepter) :
   un lien "Lire les conditions" ouvre l'URL dans `url_launcher` — optionnel(pas optionnel on le fait).

### Ce qui manque dans Flutter

`FullShipment.fromJson` ne parse pas ces deux champs → silencieusement ignorés.

### Corrections à apporter

**Fichier :** `lib/features/shipment/models/full_shipment.dart`
```dart
final bool termsAcceptanceRequired;
final String? termsAcceptanceUrl;

// dans fromJson :
termsAcceptanceRequired: json['terms_acceptance_required'] as bool? ?? false,
termsAcceptanceUrl: json['terms_acceptance_url'] as String?,
```

**Fichier :** `lib/features/messaging/screens/messaging_screen.dart` (S11)

Lire `fullShipmentProvider` (déjà accessible via `ref`) et afficher le bandeau
conditionnel en haut de l'écran si `termsAcceptanceRequired == true`.

**Nouveau service :** `lib/features/shipment/services/terms_service.dart` (ou dans
`shipment_service.dart`) — une méthode `acceptTerms(suffix)` qui appelle
`POST /api/shipment/{suffix}/terms`.

---

## 2. 🟠 Claim créée via API → état `under_review` immédiat

### Ce qui a changé côté backend

`POST /api/shipment/{suffix}/claim` appelle désormais `claim.action_submit_for_review()`
juste après la création. La claim passe directement à `under_review` sans passer par `open`.

**Avant :**
```
POST /claim  →  state = 'open'
```
**Maintenant :**
```
POST /claim  →  state = 'under_review'  (en une seule opération)
```

Le backend retourne toujours HTTP **201** avec `{"reference": "BW/CLM/2026/0001"}`.
Dio traite tous les 2xx comme succès → pas de crash côté Flutter sur ce point.

### Impact sur `_detectClaimUpdate`

Le code dans `lib/features/shipment/providers/full_shipment_provider.dart` :

```dart
// Comportement documenté : "Pas d'update sur null → open (l'utilisateur vient de déposer)"
```

Ce cas ne se produira plus. Maintenant la transition initiale est `null → under_review`,
ce qui **déclenchera un `AppUpdate`** ("Statut réclamation : En cours d'examen")
immédiatement après que l'utilisateur ait soumis sa réclamation.

L'utilisateur vient de soumettre lui-même → recevoir une notification S13 dans la
foulée est redondant et potentiellement confus.

### Correction à apporter

**Fichier :** `lib/features/shipment/providers/full_shipment_provider.dart`

Chercher la méthode `_detectClaimUpdate` et étendre la condition de skip :

```dart
// Avant :
if (previous == null && current == 'open') return;  // skip initial submission

// Après :
if (previous == null && (current == 'open' || current == 'under_review')) return;
```

Cela supprime la notification automatique pour la soumission initiale (état `open`
ou `under_review` selon la version du backend), tout en conservant les notifications
pour les transitions suivantes (accepted, refused).

---

## 3. 🟠 Plan gating — `ForwarderInfo` ne parse pas les nouveaux champs

### Ce qui a changé côté backend

`GET /api/forwarder/info` retourne **maintenant** deux champs supplémentaires :

```json
{
  "name": "BrightFret Core",
  "logo_url": "/web/image/res.company/1/logo",
  "primary_color": "#002868",
  "contact_phone": "+237 6XX XX XX XX",
  "can_create_claims": true,
  "terms_enabled": false
}
```

| Champ | Type | Signification |
|-------|------|--------------|
| `can_create_claims` | bool | `true` si plan ≥ Pro. `false` si Starter → masquer le bouton claim dans S08 |
| `terms_enabled` | bool | `true` si la feature CGU est activée (Enterprise uniquement) → conditionne S19 |

Le backend a déjà tout prévu : ces deux champs évitent que le client final voie
jamais un 403. Le bouton et les écrans doivent simplement ne pas s'afficher quand
la valeur est `false`. Le 403 reste un filet de sécurité serveur, pas un message UX.

**Tableau des paliers (pour référence) :**

| Fonctionnalité | Starter | Pro | Enterprise | Champ de contrôle |
|---|---|---|---|---|
| Réclamations | ❌ | ✅ | ✅ | `can_create_claims` |
| CGU / terms | ❌ | ❌ | ✅ | `terms_enabled` |
| Tout le reste (suivi, messagerie, documents) | ✅ | ✅ | ✅ | — |
| Bordereaux, SMS, rapport | ❌/✅/✅ | PWA Ops uniquement — pas Flutter |

### Ce qui manque dans Flutter

`ForwarderInfo.fromJson` ne parse pas `can_create_claims` ni `terms_enabled` → les deux
champs sont ignorés et le bouton claim est toujours affiché, même sur Starter.

### Corrections à apporter

**Fichier :** `lib/features/tracking/models/forwarder_info.dart`

```dart
// Ajouter les deux champs :
final bool canCreateClaims;
final bool termsEnabled;

// Dans fromJson :
canCreateClaims: json['can_create_claims'] as bool? ?? true,  // true = fallback permissif
termsEnabled: json['terms_enabled'] as bool? ?? false,
```

**Fichier :** `lib/core/models/cached_forwarder_info.dart` (HiveType 3)

Ajouter les deux champs en tant que nouveaux HiveField — utiliser des ids supérieurs
au plus grand existant pour ne pas casser les enregistrements Hive déjà stockés.

**Fichier :** `lib/features/shipment/screens/shipment_detail_screen.dart` (S08)

Le bouton/la section claim doit lire `forwarderInfoProvider` et ne s'afficher que si
`canCreateClaims == true`.

**Note sur le 403 :** avec cette correction en place, le 403 ne sera jamais visible
par un utilisateur normal. Ajouter `ForbiddenException` dans `api_exception.dart`
reste utile comme garde-fou (appel direct hors app, test) mais n'est plus prioritaire.

---

## 4. ✅ Champ `client_phone` — aucune action

Le backend retourne `client_phone` dans `GET /api/shipment/{suffix}` — c'est le numéro
du client lui-même. L'afficher à l'utilisateur dans l'app qu'il utilise sur son propre
téléphone n'a aucune utilité. Champ ignoré silencieusement par Flutter, aucune action requise.

---

## 5. ✅ Cache token — comportement déjà correct

### Recommandation du rapport de test (TEST_REPORT_V2.md, Niveau 6)

> Chaque appel réussi à `POST /verify` **invalide le token précédent** pour ce colis
> (`_create_token()` supprime l'ancien puis génère le nouveau). Si l'app rappelait
> `/verify` à chaque lancement au lieu de réutiliser un token déjà valide en cache,
> toute autre session/appareil tenant l'ancien token serait silencieusement déconnectée.
> **Recommandation :** mettre en cache le token (avec son `expires_in` de 24h) et ne
> rappeler `/verify` que si le token est absent ou expiré.

### Vérification dans l'app Flutter

L'implémentation est déjà conforme :

- **`TokenStorage.getToken()`** (`lib/core/storage/token_storage.dart`) : lit le token
  dans Hive et retourne `null` si expiré (`token.isExpired`) — jamais de rappel réseau
  sur une requête normale.
- **Router redirect** (`lib/core/router/router_notifier.dart`) : si l'utilisateur
  navigue vers `/track/:suffix/verify` mais qu'un token valide existe déjà en Hive,
  il est redirigé directement vers S08 — S07 ne s'affiche pas, `/verify` n'est pas rappelé.
- **Auth guard** : `/shipment/*` redirige vers S07 uniquement si `hasValidTokenForSuffix`
  retourne `false` (token absent ou expiré).

**Aucune modification nécessaire.** La recommandation du rapport de test est déjà
l'architecture en place.

---

## 6. ✅ Documents inline — déjà géré

Le backend retourne maintenant des documents supplémentaires pour les champs
binaires `parcel_photo` et `qr_code` directement stockés sur le modèle.
Ces entrées ont un format différent :

```json
{
  "id": "field_42_parcel_photo",
  "name": "Photo du colis",
  "mimetype": "image/png",
  "data": "iVBORw0KGgo...",
  "url": ""
}
```

`ShipmentDocument.fromJson` gère déjà les deux cas :
- `id: json['id'].toString()` → supporte les int ET les strings ✓
- `data: json['data'] as String?` → champ `data` déjà parsé ✓
- `isImage` renvoie `true` si `data != null` ✓

**Aucune modification nécessaire.**

---

## 6. ✅ Champ `cargo` — déjà géré

`FullShipment.fromJson` parse déjà `cargo` via `CargoSummary.fromJson`.
`CargoLine` et `CargoSummary` sont présents dans `lib/features/shipment/models/cargo_summary.dart`.

**Aucune modification nécessaire.**

---

## 7. ✅ `paymentStatus` 3 états — déjà géré

Le champ `payment_status` backend est `none | partial | full` (sélection Odoo).
`FullShipment.fromJson` parse `paymentStatus` comme `String` → déjà compatible.

**Aucune modification nécessaire.**

---

## 8. ✅ `GET /claims` list endpoint — déjà géré

`ClaimService.getClaims()` appelle déjà `/api/shipment/{suffix}/claims`.
`ClaimsListScreen` et `claimsListProvider` sont présents et fonctionnels.

**Aucune modification nécessaire.**

---

## Autres changements backend (pas d'impact Flutter)

### Page HTML de suivi public `/track/{suffix}`
Nouveau template QWeb rendu côté serveur. L'app Flutter n'est pas concernée :
elle continue d'appeler `/api/track/{suffix}` avec `Accept: application/json`,
qui retourne du JSON comme avant.

### CORS origin configurable
Paramètre `bw_freight.cors_allowed_origin` dans `ir.config_parameter`.
Défaut : `*`. À configurer avant exposition publique.
Aucun impact côté Flutter.

### Purge des tokens et rate-limit via cron
Deux nouveaux `ir.cron` dans `freight_cron_data.xml` pour nettoyer
`freight.rate.limit` et `freight.verify.attempt` périodiquement.
Aucun impact côté Flutter.

### Photo de réclamation (optionnelle)
`POST /api/shipment/{suffix}/claim` accepte maintenant un champ `photo`
(base64 JPEG, max 5 Mo). Non envoyé par Flutter actuellement.
À implémenter si l'UX claim doit permettre la prise de photo.

---

## Plan d'action recommandé

| Ordre | Fichier | Changement | Bloquant ? |
|-------|---------|-----------|-----------|
| 1 | `lib/features/tracking/models/forwarder_info.dart` | Ajouter `canCreateClaims` + `termsEnabled` | Oui — masque le bouton claim sur Starter |
| 2 | `lib/core/models/cached_forwarder_info.dart` | Ajouter les 2 champs HiveField (nouveaux ids) | Oui — sinon le cache Hive perd les valeurs |
| 3 | `lib/features/shipment/screens/shipment_detail_screen.dart` | Conditionner le bouton claim à `canCreateClaims` | Oui |
| 4 | `lib/features/shipment/providers/full_shipment_provider.dart` | Corriger `_detectClaimUpdate` : skip `null → under_review` | Oui — UX confuse sinon |
| 5 | `lib/core/http/api_exception.dart` | Ajouter `ForbiddenException` (403) — filet de sécurité | Non — jamais vu par l'utilisateur si #1-3 fait |
| 6 | — | `client_phone` — pas d'usage côté client, rien à faire | — |
| 7 | `lib/features/shipment/models/full_shipment.dart` + `messaging_screen.dart` | Parser `terms_acceptance_required`, bouton inline S11 | Non — dormant tant que `terms_enabled = false` |

**Points confirmés corrects (aucune action) :**
- Cache token Hive : router skip S07 si token valide — déjà correct
- Documents inline : `ShipmentDocument.fromJson` gère `data` et string `id`
- `cargo`, `paymentStatus`, liste `/claims` : tous déjà parsés
