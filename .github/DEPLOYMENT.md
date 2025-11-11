# Configuration du déploiement automatique GitHub Actions

## Secrets à configurer sur GitHub

Allez sur votre repo GitHub → Settings → Secrets and variables → Actions

### Secrets requis

1. **SSH_PRIVATE_KEY**
   - Votre clé SSH privée pour vous connecter au serveur Hostinger
   - Pour la générer si vous ne l'avez pas :
     ```bash
     ssh-keygen -t ed25519 -C "github-actions-deploy"
     # Copiez le contenu de ~/.ssh/id_ed25519
     cat ~/.ssh/id_ed25519
     ```
   - Ajoutez la clé publique sur votre serveur :
     ```bash
     ssh-copy-id root@votre-serveur.com
     # ou manuellement :
     cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
     ```

2. **SSH_HOST**
   - L'adresse IP ou le hostname de votre serveur Hostinger
   - Exemple : `srv829722.hstgr.cloud` ou `123.45.67.89`

3. **SSH_USER**
   - L'utilisateur SSH (probablement `root`)

### Variables (optionnelles)

Dans Settings → Secrets and variables → Actions → Variables tab :

- **DEPLOY_PATH** : Chemin du projet sur le serveur (défaut : `/docker/db-importer`)

## Comment ça marche

1. **Déploiement automatique** : Chaque push sur la branche `main` déclenche le déploiement
2. **Déploiement manuel** : Allez dans Actions → Deploy to Production VPS → Run workflow

## Ce que fait le workflow

1. Se connecte en SSH à votre serveur
2. Pull le code depuis GitHub
3. Rebuild les images Docker
4. Redémarre les containers
5. Affiche les logs

## Troubleshooting

### Erreur "Permission denied (publickey)"
- Vérifiez que `SSH_PRIVATE_KEY` contient votre clé privée COMPLÈTE
- Vérifiez que la clé publique est bien sur le serveur dans `~/.ssh/authorized_keys`

### Erreur "Host key verification failed"
- Normal au premier run, le workflow gère automatiquement les host keys

### Le déploiement ne se lance pas
- Vérifiez que vous avez bien poussé sur la branche `main`
- Ou lancez manuellement le workflow depuis l'onglet Actions
