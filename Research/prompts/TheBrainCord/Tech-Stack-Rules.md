# TheBrainCord: Master Technical Guidelines & Rules
**Version:** 1.0 | **Owner:** TBC-Architect

## 1. Core Philosophy (The "TBC Way")
* **Solopreneur First:** We do not build massive, unmaintainable monoliths. We build modular, containerized micro-services that one person can manage.
* **Performance is Feature #1:** If it can be static, make it static (Astro). If it needs heavy compute, write it in C++.
* **Design Signature:** Dark mode, Neon/Deep Purple Gradients, Glassmorphism, and "Sweet & Short" copy.
* **AI-Native Workflow:** Code must be written clearly enough for an AI to read, refactor, and document.

---

## 2. The Master Tech Stack

### A. Frontend (Websites & Dashboards)
* **Framework:** **Astro** (Primary). Use it for 90% of the site (Landing, Blog, About).
* **Interactivity:** **React** (Secondary). Use *only* for interactive "Islands" (Calculators, User Dashboards, TBC-Academy Logins).
* **Styling:** **Tailwind CSS**. No custom CSS files unless absolutely necessary for complex animations.
* **Animation:** **Framer Motion**. Do not use jQuery or heavy GSAP libraries unless required.
    * *Rule:* All cards must have a subtle `whileHover` scale effect.
    * *Rule:* Page transitions should be smooth fades, not jerky jumps.

### B. Backend & Logic
* **Heavy Compute:** **C++**. Use for core algorithms, driver-level tools, or high-performance data processing.
    * *Integration:* Expose C++ logic to Python using **pybind11**.
* **Business Logic & AI:** **Python (FastAPI)**. Use for gluing services together, running AI prompts, and handling API requests.
* **Database:** **PostgreSQL** (via Docker).

### C. DevOps (The "One-Man Army" Setup)
* **Infrastructure:** **Docker**. Every app (Academy, Tools, Client Sites) must have a `Dockerfile`.
* **CI/CD:** **Jenkins**.
    * *Pipeline Rule:* Commit to GitHub -> Jenkins detects change -> Builds Docker Image -> Replaces Container.
    * *No Downtime:* Use simple "Blue/Green" deployment (spin up new container, switch port, kill old container).

---

## 3. Coding Standards (Strict Rules)

### General
1.  **Comments:** Explain *Why*, not *What*. (e.g., "Refactored to reduce memory load," not "Loop through array").
2.  **Naming:** Use descriptive names. `userLoginController` is better than `ulc`.

### Astro/React Specifics
* **Islands Architecture:** Always use `client:visible` for React components to keep the initial load fast.
    * *Bad:* `<Counter client:load />` (Loads JS immediately, slows down site).
    * *Good:* `<Counter client:visible />` (Loads JS only when user scrolls to it).
* **Directories:**
    * `/src/components/ui` -> Buttons, Cards, Modals (Reusable).
    * `/src/components/feature` -> TBC-Academy-Card, GoKarnaGo-Widget (Specific).

### Tailwind Design System (Copy this to `tailwind.config.mjs`)
* **Primary Color:** `tbc-purple`: `#6b21a8` (Purple 800)
* **Accent Color:** `tbc-neon`: `#06b6d4` (Cyan 500)
* **Background:** `tbc-dark`: `#0f172a` (Slate 900)
* **Glassmorphism Utility:**
    ```css
    .glass {
      @apply bg-white/10 backdrop-blur-lg border border-white/20 shadow-xl;
    }
    ```

---

## 4. Client vs. Internal Protocol

### Protocol A: "Internal Product" (TBC-Academy, Tools)
* **Priority:** Maximum Creativity.
* **Risk:** High. (Try new beta features).
* **Branding:** Strong TBC Branding (Logo everywhere).

### Protocol B: "Client Work" (Consulting)
* **Priority:** Stability & SEO.
* **Risk:** Zero. (Use established stable versions).
* **Branding:** **Invisible.** Do not put "Powered by TheBrainCord" unless the client agrees.
* **Stack:** If the client requests WordPress, we give them WordPress (managed via Docker). Do not force our stack if it hurts their business.

---

## 5. Deployment Checklist (Before Launch)
1.  [ ] Is the Docker image size under 200MB? (Use Alpine Linux base).
2.  [ ] Are all API keys in `.env` and NOT in the code?
3.  [ ] Did we run the "Sweet & Short" copy check? (Remove 20% of the words).
4.  [ ] Is the Jenkins pipeline Green?
