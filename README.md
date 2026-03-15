# k3s-lab

# ansible

Branch 04-
You will have to generate a Docker Hub token:

hub.docker.com
→ Account Settings
→ Security
→ New Access Token
→ name it "k3s-lab"
→ permissions: Read, Write & Delete
→ copy the token (shown only once)

You will also need to run
`ansible-galaxy collection install -r ~/k3s/ansible/requirements.yml`
This is to ensure we install community.docker and can sign-in to Docker Hub cleanly without shell commands and maintain idempotency.
In addition, community.docker.docker_image can build and push Docker images to the Docker Hub registry without shell commands.

NOTE: This can be embedded in the Vagrantfile.