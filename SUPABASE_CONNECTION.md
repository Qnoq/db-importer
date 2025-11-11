# Configuration de la connexion Supabase

## Problème IPv6 résolu avec le Connection Pooler

Supabase utilise maintenant IPv6 pour les connexions directes (`db.xxxxx.supabase.co`).
Si votre serveur ne supporte pas IPv6, la connexion échouera avec :
```
dial tcp [2a05:...]:5432: connect: cannot assign requested address
```

**Solution recommandée** : Utiliser le **Connection Pooler** de Supabase qui supporte IPv4 + IPv6.

## Comment obtenir l'URL du Connection Pooler

1. Allez sur votre dashboard Supabase : https://supabase.com/dashboard
2. Sélectionnez votre projet
3. Allez dans **Project Settings** (⚙️ en bas à gauche)
4. Cliquez sur **Database** dans le menu latéral
5. Descendez jusqu'à **Connection pooling**
6. Copiez l'URL en **Session mode** (recommandé pour les migrations)

L'URL ressemblera à :
```
postgresql://postgres.xxxxx:[PASSWORD]@aws-0-region.pooler.supabase.com:5432/postgres
```

## Configuration dans votre application

### Sur votre serveur de production

Créez/éditez le fichier `.env` dans `/docker/db-importer/` :

```bash
# Au lieu de l'ancienne URL directe :
# DATABASE_URL=postgresql://postgres:[PASSWORD]@db.xxxxx.supabase.co:5432/postgres

# Utilisez l'URL du pooler :
DATABASE_URL=postgresql://postgres.xxxxx:[PASSWORD]@aws-0-region.pooler.supabase.com:5432/postgres
```

**Important** : Remplacez `[PASSWORD]` par votre vrai mot de passe !

### Trouver votre mot de passe

Dans le dashboard Supabase :
- **Project Settings** → **Database**
- Le mot de passe est affiché dans la section **Connection string**
- OU cliquez sur **Reset database password** si vous l'avez oublié

## Avantages du Connection Pooler

✅ **Dual-stack** : Fonctionne avec IPv4 ET IPv6
✅ **Connection pooling** : Meilleure performance pour les apps en production
✅ **Gratuit** : Inclus dans tous les plans Supabase
✅ **Pas de configuration réseau** : Aucun changement sur le serveur requis
✅ **Scalabilité** : Gère automatiquement beaucoup de connexions simultanées

## Modes de pooling disponibles

- **Session mode** (recommandé pour cette app) : Compatible avec les migrations et toutes les fonctionnalités PostgreSQL
- **Transaction mode** : Plus rapide mais limité, pour des requêtes SQL simples

Pour cette application, utilisez **Session mode**.

## Après avoir changé l'URL

Redémarrez votre application :

```bash
cd /docker/db-importer
docker compose down
docker compose up -d
docker compose logs backend -f
```

Vous devriez voir :
```
✅ Database connection established successfully
Database migrations completed successfully
```

## Troubleshooting

### Erreur "connection refused"
- Vérifiez que vous avez copié l'URL complète incluant le mot de passe
- Assurez-vous d'utiliser l'URL du **pooler** (`.pooler.supabase.com`) et non la directe (`db.xxx.supabase.co`)

### Erreur "SSL connection required"
- Ajoutez `?sslmode=require` à la fin de votre URL si nécessaire

### Les migrations échouent encore
- Vérifiez que vous utilisez le **Session mode** du pooler, pas Transaction mode
- Le Session mode est requis pour les migrations (DDL statements)

## Références

- [Article Medium sur le problème IPv6 Supabase](https://medium.com/@lhc1990/solving-supabase-ipv6-connection-issues-96f8481f42c1)
- [Documentation Supabase Connection Pooling](https://supabase.com/docs/guides/database/connecting-to-postgres#connection-pooler)
