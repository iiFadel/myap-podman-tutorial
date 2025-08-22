# Podman Hands-On Lab: Your First Container Journey



## What You'll Learn Today

By the end of this session, you'll:

- Understand what Podman is and why containers matter
- Build your first container image using Red Hat UBI
- Run and manage containers like a pro

---

## Part 1: Understanding Podman and Containers

### What is Podman?
Podman (Pod Manager) is a container engine that lets you develop, manage, and run containers on your Linux systems. Think of it as a tool that packages your applications with everything they need to run consistently anywhere.

### Why Use Red Hat UBI?
Universal Base Images (UBI) are enterprise-grade base images that are:

- **Secure:** Regularly updated with security patches  
- **Supported:** Backed by Red Hat  
- **Compliant:** Meet enterprise security standards  
- **Free:** Available for use and redistribution  

### Why Containers Matter
Imagine you've built a web application that works perfectly on your laptop, but on your colleague's machine, it fails due to different software versions. Containers solve this by:

- **Portability:** "It works on my machine" becomes "It works everywhere"  
- **Consistency:** Same environment from development to production  
- **Isolation:** Applications don't interfere with each other  
- **Efficiency:** Lightweight compared to virtual machines  

---

## Part 2: Lab Setup and Prerequisites

### What We're Building
Today we'll containerize a simple web application using the provided files:

- `index.html` - Our main web page  
- `community-logo.png` - Qatif OpenSource logo image  
- `redhat-logo.png` - Red Hat lgo image  
- `README.md` - Project documentation  
- `Containerfile` - Instructions for building our container  

### Prerequisites Check

```bash
# Check if Podman is installed
podman --version

# Check if you can run containers (should show system info)
podman info

# Verify your files are present
ls -la
```
You should see: Containerfile, index.html, community-logo.png, redhat-logo.png, README.md

## Part 3: Your First Container Build

### Step 1: Understanding Your Containerfile
Let's examine your Containerfile that uses Red Hat's UBI with Apache HTTP Server:

```dockerfile
FROM registry.access.redhat.com/ubi9/httpd-24:1-321.1717085244

# Add application sources to the Apache document root
COPY index.html /var/www/html/
COPY community-logo.png /var/www/html/
COPY redhat-logo.png /var/www/html/
COPY README.md /var/www/html/

# The run script uses standard ways to run the application
CMD run-httpd
```

What's happening here?

- `FROM registry.access.redhat.com/ubi9/httpd-24:1-321.1717085244`: We start with Red Hat's UBI 9 image that includes Apache HTTP Server 2.4
- `COPY index.html /var/www/html/`: Copy the main web page to Apache's document root
- `COPY community-logo.png /var/www/html/`: Copy the community logo image
- `COPY redhat-logo.png /var/www/html/`: Copy the Red Hat logo image
- `COPY README.md /var/www/html/`: Copy documentation to be web-accessible
- `CMD run-httpd`: Uses the built-in script to start Apache HTTP Server

Why this structure is excellent:

- **Clear organization**: Each file is explicitly copied
- **Proper destination**: All files go to `/var/www/html/` (Apache's document root)
- **Complete web assets**: HTML, images, and documentation all included
- **Enterprise-ready**: Uses Red Hat UBI for production reliability

### Step 2: Build Your First Image

```bash
# Build the image and tag it as "my-web-app"
podman build -t my-web-app .

# The dot (.) tells Podman to look for the Containerfile in the current directory
```

Watch the magic happen! You'll see Podman:

- Download the Red Hat UBI httpd base image (if not already cached)
- Copy `index.html` to `/var/www/html/`
- Copy `community-logo.png` to `/var/www/html/`
- Copy `redhat-logo.png` to `/var/www/html/`
- Copy `README.md` to `/var/www/html/`
- Create a new image tagged "my-web-app"

### Step 3: Verify Your Image

```bash
# List all images on your system
podman images

# Inspect your image to see the layers
podman inspect my-web-app

# Check the build history
podman history my-web-app
```

You should see your `my-web-app` image listed along with the base UBI image!

## Part 4: Running Your Container

### Step 1: Run Your Container

```bash
# Run the container and map port 8080 on your host to port 8080 in the container
podman run -d -p 8080:8080 --name my-webapp my-web-app
```

Breaking down this command:

- `-d`: Run in detached mode (background)
- `-p 8080:8080`: Map host port 8080 to container port 8080 (UBI httpd uses port 8080 by default)
- `--name my-webapp`: Give the container a friendly name
- `my-web-app`: The image to run

### Step 2: Check Your Running Container

```bash
# List running containers
podman ps

# Verify all files were copied correctly
podman exec my-webapp ls -la /var/www/html/
```

You should see all your files:

- `index.html`
- `community-logo.png`
- `redhat-logo.png`
- `README.md`

### Step 3: Test Your Web Application
Open your web browser and navigate to: `http://localhost:8080`

You can also access individual files:

- `http://localhost:8080/index.html` - Your main page (should display with logos)
- `http://localhost:8080/README.md` - Your documentation
- `http://localhost:8080/community-logo.png` - Community logo image
- `http://localhost:8080/redhat-logo.png` - Red Hat logo image

🎉 Congratulations! You've just containerized and deployed your first application with Red Hat branding!


## Part 5: Hands-On Exercises

### Exercise 1: Verify Your Complete Web Application
Start your container:

```bash
podman run -d -p 8080:8080 --name webapp-test my-web-app
```

Test all your assets:

```bash
# Check that all files are present
podman exec webapp-test ls -la /var/www/html/

# Verify file types
podman exec webapp-test file /var/www/html/*

# Check image file sizes
podman exec webapp-test ls -lh /var/www/html/*.png
```

Access via web browser:

- Main page: `http://localhost:8080`
- Documentation: `http://localhost:8080/README.md`
- Direct image access: `http://localhost:8080/community-logo.png`
- Red Hat logo: `http://localhost:8080/redhat-logo.png`

Monitor access logs:

```bash
# In one terminal, watch logs
podman logs -f webapp-test

# In another terminal or browser, access different files
curl http://localhost:8080/index.html
curl http://localhost:8080/community-logo.png
curl http://localhost:8080/redhat-logo.png
```


### Exercise 2: Development Workflow
Make changes to your HTML file (simulate development):

```bash
# Backup original
cp index.html index.html.backup

# Make a change
echo "<h1>Updated Page</h1><p>Now with container deployment!</p>" > index.html
```

Rebuild and redeploy:

```bash
podman build -t my-web-app:v2 .
podman stop my-webapp
podman run -d -p 8080:8080 --name my-webapp-v2 my-web-app:v2
```

Test the update:

```bash
curl http://localhost:8080/index.html
```

Rollback if needed:

```bash
# Restore original file
cp index.html.backup index.html

# Rebuild original version
podman build -t my-web-app:v1 .
podman stop my-webapp-v2
podman run -d -p 8080:8080 --name my-webapp-v1 my-web-app:v1
```

### Exercise 3: Multi-Environment Testing
Run different versions simultaneously:

```bash
# Development version
podman run -d -p 8080:8080 --name dev-webapp my-web-app:v1

# Staging version
podman run -d -p 8081:8080 --name staging-webapp my-web-app:v2
```

Test both environments:

- Development: `http://localhost:8080`
- Staging: `http://localhost:8081`

Compare access patterns:

```bash
podman logs dev-webapp
podman logs staging-webapp
```
