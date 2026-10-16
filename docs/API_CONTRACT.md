# Contrat API Clean237 v3

Cette documentation suit le contrat backend décrit dans `D:\clean237-backend\docs\API.md`.
La base de toutes les routes est `/api/v1`. Les identifiants MongoDB sont des ObjectId
de 24 caractères hexadécimaux.

## Formats communs

- Succès : `{ "message": "...", ... }`.
- Erreur : `{ "status": 4xx|5xx, "message": "..." }`. L'interface affiche `message`
  sans le remplacer par un texte générique.
- Liste : `{ "message": "...", "data": [...], "pagination": { "page", "limit",
  "total", "totalPages" } }`.
- Les dates ISO sont converties en `DateTime` UTC dans les DTOs et envoyées en UTC.

## Routes utilisées par le frontend

### Tableau de bord

- `GET /dashboard` -> `dashboard.totalZones`, `totalDataPoints`, `dataByType`,
  `totalAnalyses`, `analysesWithResult`, `totalReports`, `reportsWithStats`,
  `zonesCritiques`, `alertesActives`.
- `GET /dashboard/zones/problematic` -> `zones[]` : `zoneId`, `nom`, `score`,
  `niveau`, `details.alertScore`, `details.alertCount`, `details.dataCount`,
  `details.derniereDonnee`.

### Zones et données environnementales

- `GET /zones` -> `{ zones: [{ _id, nom }] }`.
- `GET /zones/:id` -> `{ zone }`.
- `GET /zones/:id/details` -> `{ zone: { _id, nom, score, niveau,
  evolutionPoints, derniereMiseAJour, evolution30Jours: [{ date, score }],
  alertCount, dataCount, interpretation, priorites } }`.
- `GET /donnees-environnementales?zoneId&type&page&limit&sort&order` -> liste paginée
  des données environnementales.
- `GET /donnees-environnementales/:id` -> `{ donnee }`.

### Alertes

- `GET /alertes?severite&zoneId&statut&search&page&limit` -> liste paginée de
  `{ _id, titre, sousTitre, zoneId, zoneNom, date, severite, statut }`.
- `GET /alertes/:id` -> `{ alerte }`.
- `PATCH /alertes/:id/traiter` -> `{ alerte }`. La vue locale est actualisée après
  confirmation du backend.
- `severite`: `critique | avertissement | info`; `statut`: `active | traitee`.

### Analyses

- `POST /analyses/generate` avec `{ type?, zoneId?, periode?: { start, end } }`
  -> `{ analyse }`. La réponse comprend `type`, `zoneId?`, `zoneNom?`, `periode`,
  `resultat`, `indicateurs.totalPoints`, `indicateurs.parType`, `createdAt`.
- `GET /analyses/:id` -> `{ analyse }`.
- Le backend retourne 404 quand aucune donnée ne correspond à la période.

### Rapports

- `POST /rapports/generate` avec `{ titre, description?, analyseId, type?,
  format?: "pdf"|"csv" }` -> `{ report }`.
- `GET /rapports?page&limit&sort&order&search&statut&type&zoneId` -> liste paginée.
- `GET /rapports/:id` -> `{ report }`.
- `DELETE /rapports/:id`.
- `PATCH /rapports/:id/statut` avec `{ statut }` -> `{ report }`.
- `GET /rapports/:id/export?format=pdf|csv` -> fichier binaire.
- `statut`: `pret | en_cours | archive`; `format`: `pdf | csv`. Excel n'est pas
  pris en charge par l'API.

## Conversions des mappers

- Le score backend mesure la gravité (un score élevé est plus grave) :
  `scoreSante = 100 - score`. La même conversion est appliquée à chaque point du
  graphique historique.
- `critique` -> `critical`; `problématique` et `à surveiller` -> `warning`;
  `normal` -> `normal`.
- `critique | avertissement | info` est converti vers l'enum de sévérité d'alerte.
- Les DTOs tolèrent l'absence des champs optionnels. `analyseId` peut être une chaîne
  ObjectId ou un document Analyse peuplé.

## Sources mock et API

`--dart-define=USE_MOCK_API=true|false` choisit la source dans le point d'entrée.
Le mock suit les mêmes enveloppes JSON, noms de champs, identifiants ObjectId et
formats de pagination que le contrat v3. Les erreurs simulées conservent le champ
`message` attendu de l'API.

## Éléments d'écran sans source backend

Les cases cochées des priorités sont uniquement un état local temporaire et ne
représentent pas une opération persistée. Le choix de l'utilisateur pour les périodes
prédéfinies ou personnalisées, les filtres et le texte de recherche sont également
des états d'interface, pas des données enregistrées par le backend.
