# ⚡ Quick Start - DB Importer

Guide ultra-rapide pour lancer le projet en 30 secondes ! 🚀

---

## 🎯 Lancer le projet (une seule commande !)

```bash
./dev.sh
```

Ou avec Make :
```bash
make dev
```

**C'est tout !** 🎉

Le script va :
1. ✅ Vérifier Go et Node.js
2. ✅ Installer Air automatiquement (si pas installé)
3. ✅ Créer les liens .env
4. ✅ Installer les dépendances (si besoin)
5. ✅ Lancer le backend avec hot reload (Air)
6. ✅ Lancer le frontend avec hot reload (Vite)

---

## 🌐 Accéder à l'application

- **Frontend** : http://localhost:5173
- **Backend API** : http://localhost:8080

---

## 🛑 Arrêter le projet

**Méthode 1** : Dans le terminal où dev.sh tourne
```bash
Ctrl+C
```

**Méthode 2** : Depuis un autre terminal
```bash
./stop.sh
```

Ou avec Make :
```bash
make stop
```

---

## 📋 Voir les logs

Le script `dev.sh` affiche les logs du frontend par défaut.

Pour voir les logs du backend dans un autre terminal :
```bash
tail -f backend.log
```

Ou avec Make :
```bash
make logs-backend    # Logs backend
make logs-frontend   # Logs frontend
```

---

## 🧹 Autres commandes utiles

```bash
make install   # Installer toutes les dépendances
make clean     # Nettoyer les fichiers temporaires
make help      # Afficher l'aide
```

---

## 📚 Documentation complète

Pour plus de détails sur le setup complet, consulte :
- **DEV.md** - Guide de développement complet
- **MIGRATION.md** - Explication de la configuration Supabase

---

## 🎯 Workflow de développement

1. **Lancer le projet** : `./dev.sh`
2. **Développer** : Modifie ton code
3. **Hot reload automatique** : Les changements sont appliqués instantanément
4. **Tester** : http://localhost:5173
5. **Arrêter** : `Ctrl+C` ou `./stop.sh`

---

**C'est aussi simple que ça ! 🚀**
