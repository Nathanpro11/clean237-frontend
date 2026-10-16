# Audit Frontend – module administration_reporting

## Vue d’ensemble

Le module actuel est piloté par des données de démonstration stockées dans `AdminMockDataSource` et par des modèles de domaine orientés UI. L’objectif est de les remplacer progressivement par le contrat backend `/api/v1`, sans casser l’architecture MVVM existante.

## Tableau d’audit

| Écran / widget | Donnée affichée | Champ du contrat | Décision |
| --- | --- | --- | --- |
| Dashboard | totalZones | `dashboard.totalZones` | GARDER |
| Dashboard | totalDataPoints | `dashboard.totalDataPoints` | GARDER |
| Dashboard | `dataByType[alerte]` | `dashboard.dataByType.alerte` | GARDER (libellé honnête, sans navigation) |
| Dashboard | totalAnalyses | `dashboard.totalAnalyses` | GARDER |
| Dashboard | totalReports | `dashboard.totalReports` | GARDER |
| Dashboard | zonesCritiques | `dashboard.zonesCritiques` | GARDER |
| Dashboard | section “Zones à surveiller” | `/dashboard/zones/problematic` | GARDER (3 premières zones non normales) |
| Dashboard | alertes récentes | — | SUPPRIMER |
| Zones | liste de zones | `/dashboard/zones/problematic` | FUSIONNER en page Zones |
| Zones | score santé / niveau / alertCount etc. | `score`, `niveau`, `details.alertCount` | TRANSFORMER |
| Détail zone | nom, score, niveau, alertCount, dataCount, derniereDonnee | `/zones/:id` + `/donnees-environnementales?zoneId=` | TRANSFORMER |
| Détail zone | graphique 30 jours | — | SUPPRIMER |
| Détail zone | interprétation / priorités | — | SUPPRIMER |
| Détail zone | boutons “Générer une analyse / un rapport” | — | SUPPRIMER |
| Alertes | liste, détail, traitement | — | SUPPRIMER |
| Analyse approfondie | page de zone | — | SUPPRIMER |
| Analyse | nouvelle analyse | `POST /analyses/generate` | GARDER |
| Analyse | résultat texte + indicateurs | `analyse.resultat`, `analyse.indicateurs` | GARDER |
| Rapports | liste paginée | `GET /rapports` | TRANSFORMER |
| Rapports | filtre statut / badges | — | SUPPRIMER |
| Rapports | aperçu | `GET /rapports/:id` | GARDER |
| Rapports | PDF télécharger / ouvrir | `GET /rapports/:id/pdf` | GARDER |
| Export succès / échec | messages de retour | — | GARDER |

## Décisions clés

- Les écrans non couverts par le backend réel sont supprimés ou neutralisés.
- Les valeurs affichées proviennent exclusivement d’un champ du contrat.
- Le mock reste disponible pour les tests et pour les simulations locales via `USE_MOCK_API`.
