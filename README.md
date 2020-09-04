# docker-ingress
Ingress based on Traefik:v2.2 and Docker Swarm with support TLS1.2 and TLS1.3 only.

# How to use it?

1. Clone this repo to your location:
    ```shell script
    $> git clone https://github.com/cardinalit/docker-ingress.git
    $> cd docker-ingress/
    ```

2. Copy example files without postfix _example_:
    ```shell script
    $> cp traefik/acme.example.json traefik/acme.json
    $> cp traefik/traefik.example.yml traefik/traefik.yml
    ```
   
3. Replace email setting in `traefik/traefik.yml:32` on your valid email address:
    ```yml
    29  certificatesResolvers:
    30    myResolver:
    31      acme:
    32        email: "your_email_here@example.com"
    33        storage: "/etc/traefik/acme.json"
    34        httpChallenge:
    35          entryPoint: web
    ```
    or you can run following commands without the edit manually:  
    ```shell script
    $> export MY_EMAIL=yourValidEmail@example.com 
    $> sed 's/your_email_here@example.com/'"$MY_EMAIL"'/g' -i traefik/traefik.yml
    ```

4. Change rights on `traefik/acme.json`:
    ```shell script
    $> chmod 0600 traefik/acme.json
    ```
   
5. Run stack:
    ```shell script
    $> docker stack up -c docker-ingress.yml ingress
    ```
   
6. After success running stack, you could see Traefik dashboard on `http://${IP}:8080`.
7. Enjoy!

> **NOTES**
>
> All external configuration files you can move to `traefik/traefik.conf.d/` without restart stack or container
> with ingress. Traefik will automatically read new files from there.