# Mapping Component - Édition Inline

## 🚀 Nouvelle Fonctionnalité : Édition des Cellules en Double-Clic

Le composant `Mapping.vue` a été amélioré pour permettre l'édition directe des valeurs dans la preview avant la génération des INSERT SQL.

## ✨ Fonctionnalités Principales

### 1. **Édition Inline des Cellules**
- **Double-cliquez** sur n'importe quelle cellule dans la preview pour la modifier
- Les modifications sont **sauvegardées automatiquement** en appuyant sur Enter ou en cliquant ailleurs
- **Échap** pour annuler les modifications en cours

### 2. **Validation en Temps Réel**
- Les cellules avec des erreurs sont **surlignées en rouge**
- Les warnings apparaissent avec une **icône d'avertissement** ⚠️
- Compteur d'erreurs visible dans l'en-tête

### 3. **Gestion des Types de Données**
Le composant **convertit automatiquement** les valeurs selon le type de champ :
- `int/integer/bigint` → Conversion en nombre entier
- `decimal/float/double` → Conversion en nombre décimal
- `boolean/bool` → Conversion true/false ou 1/0
- `date/datetime` → Conservé comme string (géré par le backend)
- Autres types → Conservés comme strings

### 4. **Persistance des Modifications**
- Les modifications sont **stockées séparément** des données originales
- Bouton "**Reset Changes**" pour revenir aux données originales
- Les overrides sont **appliqués lors de la génération SQL**

## 📝 Comment Utiliser

### Installation

1. **Remplacer** votre fichier `Mapping.vue` actuel par la nouvelle version
2. **Ajouter** les dépendances dans votre projet :

```bash
# Si vous n'avez pas déjà ces fichiers, créez-les :
cp useToast.ts ~/your-project/frontend/src/composables/
cp mappingStore.ts ~/your-project/frontend/src/stores/
cp types.ts ~/your-project/frontend/src/types/
```

### Utilisation dans votre Application

```vue
<template>
  <Mapping
    :selected-table="currentTable"
    :excel-data="uploadedData"
    :excel-headers="dataHeaders"
    @update:mapping="handleMappingUpdate"
    @generate="handleSQLGeneration"
  />
</template>

<script setup lang="ts">
import Mapping from '@/components/Mapping.vue'
import { ref } from 'vue'

const currentTable = ref(/* votre table schema */)
const uploadedData = ref([/* vos données Excel */])
const dataHeaders = ref([/* les headers Excel */])

function handleMappingUpdate(mapping) {
  console.log('Mapping mis à jour:', mapping)
}

function handleSQLGeneration(result) {
  console.log('SQL généré:', result.sql)
  console.log('Données finales:', result.data)
  console.log('Options:', result.options)
}
</script>
```

## 🎯 Workflow Typique

1. **Upload** du fichier Excel/CSV
2. **Sélection** de la table cible
3. **Auto-mapping** ou mapping manuel des colonnes
4. **Preview** des données avec validation
5. **Double-clic** sur les cellules à modifier :
   - Corriger les erreurs de données
   - Ajuster les valeurs incorrectes
   - Remplir les champs manquants
6. **Génération** du SQL avec les données modifiées

## 🔧 Options de Génération SQL

Le composant offre plusieurs options pour la génération SQL :

- **Include TRUNCATE** : Vide la table avant l'insertion
- **Use Transaction** : Wrap les INSERT dans BEGIN/COMMIT
- **Continue on Errors** : Continue même si une insertion échoue
- **Include Comments** : Ajoute des commentaires dans le SQL

## 🎨 Interface Utilisateur

### Indicateurs Visuels

- 🟢 **Vert** : Champs correctement mappés et valides
- 🔴 **Rouge** : Champs requis non mappés ou avec erreurs
- 🔵 **Bleu** : Cellule en cours d'édition
- 🟡 **Jaune** : Ligne avec warnings

### Actions Disponibles

- **Auto-Map** : Mapping automatique basé sur la similarité des noms
- **Clear** : Effacer tous les mappings
- **Show More** : Afficher plus de lignes dans la preview
- **Reset Changes** : Annuler toutes les modifications
- **Copy** : Copier le SQL généré
- **Download** : Télécharger le fichier SQL

## 💡 Conseils d'Utilisation

1. **Validation Préalable** : Vérifiez toujours les warnings avant de générer le SQL
2. **Batch Processing** : Pour de gros volumes, utilisez l'option de batch size
3. **Backup** : Utilisez les transactions pour pouvoir rollback si nécessaire
4. **Testing** : Testez d'abord sur une base de développement

## 🐛 Troubleshooting

### Problème : Les modifications ne sont pas sauvegardées
**Solution** : Assurez-vous d'appuyer sur Enter ou de cliquer en dehors de la cellule

### Problème : Erreur de conversion de type
**Solution** : Vérifiez que la valeur saisie correspond au type attendu

### Problème : Performance lente avec beaucoup de données
**Solution** : Limitez la preview à 10-20 lignes et utilisez "Show More" au besoin

## 📚 Structure des Données

### DataOverrides
Les modifications sont stockées dans un objet structuré :
```javascript
{
  "0": { "column1": "nouvelle valeur" },  // Row 0
  "1": { "column2": "autre valeur" },     // Row 1
}
```

### SQL Generation
Le SQL final intègre automatiquement les overrides :
```sql
-- Données originales + modifications
INSERT INTO table (col1, col2) VALUES ('valeur modifiée', 'valeur originale');
```

## 🔄 Intégration Backend

Le backend doit supporter :
- Réception du mapping complet
- Application des overrides sur les données
- Validation des types de données
- Génération SQL sécurisée (échappement des caractères)

## 📈 Améliorations Futures Possibles

- [ ] Édition en masse (sélection multiple)
- [ ] Undo/Redo pour les modifications
- [ ] Validation regex personnalisée
- [ ] Import/Export des mappings
- [ ] Templates de mapping réutilisables
- [ ] Édition inline des formules (calculs)
- [ ] Historique des modifications

## 🤝 Support

Pour toute question ou problème :
1. Vérifiez d'abord ce README
2. Consultez les logs de la console
3. Testez avec un petit échantillon de données

---

*Version 2.0 - Édition Inline Activée* 🎉
