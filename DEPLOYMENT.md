# GitHub Pages Deployment Guide

This guide will help you deploy your aVocaDo Flutter PWA to GitHub Pages.

## Prerequisites

- A GitHub account
- Git installed on your local machine
- Flutter SDK installed

## Step-by-Step Setup

### 1. Create GitHub Repository

1. Go to [GitHub](https://github.com) and create a new repository
2. **Important**: Name your repository `avocado-pwa` (not `avocado_pwa`)
3. Make it public (required for GitHub Pages on free accounts)
4. Don't initialize with README, .gitignore, or license (we already have these files)

### 2. Connect Local Project to GitHub

Run these commands in your project directory:

```bash
# Initialize git repository (if not already done)
git init

# Add your GitHub repository as remote
git remote add origin https://github.com/[YOUR-USERNAME]/avocado-pwa.git

# Add all files to git
git add .

# Create initial commit
git commit -m "Initial commit: Flutter PWA vocabulary learning app"

# Push to GitHub
git push -u origin main
```

### 3. Enable GitHub Pages

1. Go to your repository on GitHub
2. Click on **Settings** tab
3. Scroll down to **Pages** section in the left sidebar
4. Under **Source**, select **GitHub Actions**
5. The deployment workflow is already configured and will run automatically

### 4. Wait for Deployment

- The GitHub Actions workflow will automatically trigger when you push to the main branch
- You can monitor the deployment progress in the **Actions** tab of your repository
- First deployment usually takes 3-5 minutes

### 5. Access Your PWA

Once deployed, your app will be available at:
```
https://[YOUR-USERNAME].github.io/avocado-pwa/
```

## Local Testing

To test the build locally before deploying:

```bash
# Run the deployment script
./deploy.sh

# Or manually build
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter build web --release --base-href "/avocado-pwa/"
```

## PWA Features on GitHub Pages

Your app includes PWA features that work on GitHub Pages:

- **Offline Support**: The app will work offline after initial load
- **Install Prompt**: Users can install the app on their devices
- **Responsive Design**: Optimized for mobile and desktop
- **App Icons**: Custom icons for home screen installation

## Troubleshooting

### Common Issues

1. **404 Error**: Make sure the repository name is exactly `avocado-pwa`
2. **Assets Not Loading**: Verify the base href is set to `/avocado-pwa/`
3. **Build Failures**: Check that all dependencies are properly listed in `pubspec.yaml`

### Workflow Permissions

If deployment fails due to permissions:

1. Go to repository **Settings** > **Actions** > **General**
2. Under **Workflow permissions**, select **Read and write permissions**
3. Re-run the failed workflow

### Force Rebuild

To force a new deployment:

```bash
git commit --allow-empty -m "Force rebuild"
git push
```

## Updating Your App

To deploy updates:

1. Make your changes
2. Commit and push to the main branch:
   ```bash
   git add .
   git commit -m "Your update message"
   git push
   ```
3. GitHub Actions will automatically deploy the updates

## Custom Domain (Optional)

To use a custom domain:

1. Add a `CNAME` file to the `web/` directory with your domain
2. Configure DNS settings with your domain provider
3. Update the base href in the workflow and manifest.json

Your aVocaDo PWA vocabulary learning app is now ready for GitHub Pages deployment!