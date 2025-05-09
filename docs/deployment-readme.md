# MiaMilo Designs Deployment Guide

This guide outlines the process for developing and deploying design proposals to the MiaMilo Designs website.

## Project Structure

```
miamilo-designs/
├── src/                         # Source files (development)
│   ├── index.html               # Main landing page
│   ├── proposal1/               # First proposal 
│   │   ├── index.html          
│   │   ├── css/                # Proposal-specific styles
│   │   │   └── main.css
│   │   └── js/                 
│   ├── proposal2/               # Second proposal
│   │   ├── index.html
│   │   ├── css/
│   │   │   └── main.css
│   │   └── js/
│   ├── shared/                  # Shared resources
│   │   ├── css/                
│   │   └── js/                 
│   └── images/                  # All images 
│       ├── charms/
│       ├── in-the-wild/
│       ├── logos/
│       ├── backgrounds/
│       └── products/
├── public/                      # Build output (production)
└── scripts/                     # Build and deployment scripts
    ├── image-build.js           # Processes files for production
    └── upload-images.sh         # Uploads images to persistent storage
```

## Development Workflow

### 1. Local Development

Start the development server from the `src` directory:

```bash
cd src
python3 -m http.server 8080
```

Access the development server at:
- Main page: http://localhost:8080/
- Proposals: http://localhost:8080/proposal1/

### 2. Creating New Proposals

1. Create a new directory under `src` with the naming pattern `proposal#`:

```bash
mkdir -p src/proposal#/css src/proposal#/js
```

2. Create an `index.html` file in the new proposal directory
3. Create a `main.css` file in the proposal's `css` directory
4. Reference CSS files with **relative paths**:

```html
<!-- CORRECT - Use relative path with no leading slash -->
<link rel="stylesheet" href="css/main.css">

<!-- INCORRECT - Don't use paths with leading slashes -->
<link rel="stylesheet" href="/css/main.css">
```

5. Reference images using relative paths:

```html
<!-- From proposal directories -->
<img src="../images/category/image.jpg">

<!-- From root index.html -->
<img src="images/category/image.jpg">
```

### 3. Adding New Image Categories

1. Create a new directory under `src/images/`:

```bash
mkdir -p src/images/new-category
```

2. The build script will automatically detect new image categories

## Deployment Process

### 1. Build for Production

Run the build script from the project root:

```bash
node scripts/image-build.js
```

This script:
- Copies all files from `src` to `public`
- Processes HTML/CSS files to replace relative image paths with absolute paths
- Creates necessary deployment files (Dockerfile, nginx.conf, fly.toml)
- Preserves relative paths to CSS and JS files

### 2. Deploy Web Files

Deploy the web application structure:

```bash
cd public
fly deploy -a miamilo-designs
```

### 3. Upload Images

Upload images to the persistent storage:

```bash
./scripts/upload-images.sh
```

This script:
- Automatically discovers all image categories in `src/images/`
- Creates necessary directories on the server
- Uploads all images to the correct locations

## Troubleshooting

### CSS Files Not Loading

1. Ensure CSS paths in HTML files use relative paths without leading slashes:
   - Correct: `href="css/main.css"`
   - Incorrect: `href="/css/main.css"` or `href="../css/main.css"`

2. Verify the CSS file exists in the correct location:
   - Should be in `proposal#/css/main.css`

### Images Not Displaying

1. Check if the image is uploaded:
   - Run `./scripts/upload-images.sh` to upload all images
   - Verify the image URL: `https://miamilo-designs.fly.dev/images/category/filename`

2. Verify the image path in HTML:
   - From proposal directories: `../images/category/image.jpg`
   - From root index.html: `images/category/image.jpg`

### Deployment Issues

1. Clear browser cache or use incognito mode
2. Force a fresh deployment:
   ```bash
   cd public
   fly deploy -a miamilo-designs --force
   ```

## Additional Resources

- Fly.io Documentation: https://fly.io/docs/
- NGINX Configuration: https://nginx.org/en/docs/
- Local Python HTTP Server: https://docs.python.org/3/library/http.server.html
