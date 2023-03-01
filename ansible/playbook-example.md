```
$ cat dockervars.yml
---
  username: "enter your dockerhub username"
password: "enter your dockerhub password"
```
```
$ cat git.yml
---
  - name: "deploying docker from git"
  hosts: build
    become: true
  vars_files:
    - dockervars.yml
  vars:
    pkg:
      - docker
      - git
      - pip
    url: "https://github.com/antony-a-n/devops-flask.git"
    clone: "/var/flaskapp"
    img: "antonyanlinux/flask"

  tasks:
    - name: "installing packages"
      yum:
        name: "{{pkg}}"
        state: present
        
            - name: "adding user to docker group"
      user:
        name: "ec2-user"
        groups:
          - docker
        append: true

    - name: "installing python module"
      pip:
        name: docker-py

    - name: "restarting service"
      service:
        name: docker
                state: restarted
                        enabled: true

    - name: "creating document-root"
      file:
        path: "{{clone}}"
        state: "directory"

    - name: "cloning-repo"
      git:
        repo: "{{url}}"
        dest: "{{clone}}"
      register: clone_state
          - name: "login"
      when: clone_state.changed
      docker_login:
        username: "{{username}}"
        password: "{{password}}"
        state: present
        
            - name: "image building"
      when: clone_state.changed
      docker_image:
        source: build
                build:
          path: "{{clone}}"
          pull: true
        name: "{{img}}"
        tag: "{{item}}"
        push: true
        force_tag: true
        force_source: true
      with_items:
        - latest
        - "{{clone_state.after}}"

    - name: "removing local image"
      when: clone_state.changed
      docker_image:
        state: absent
                name: "{{img}}"
        tag: "{{item}}"
      with_items:
        - latest
        - "{{clone_state.after}}"

    - name: "logout"
      when: clone_state.changed
      docker_login:
        username: "{{username}}"
        password: "{{password}}"
        state: absent
        
        - name: "testing image"
  hosts: test
    become: true
  vars:
    test_img: "antonyanlinux/flask"
    test_pkg:
      - docker
      - pip

  tasks:
    - name: "package installation"
      yum:
        name: "{{test_pkg}}"
        state: "present"
    - name: "attaching user"
      user:
        name: "ec2-user"
        groups:
          - docker
        append: true

    - name: "installing module"
      pip:
        name: docker-py
    - name: "restarting service"
      service:
        name: docker
                state: started
                        enabled: true
    - name: "pulling image"
      docker_image:
        name: "{{test_img}}"
        source: pull
                force_source: true
      register: image_stat
      
          - name: "creating docker container"
      when: image_stat.changed
      docker_container:
        name: flaskdemo
                image: "{{test_img}}:latest"
        recreate: yes
                pull : yes
                        published_ports:
          - "80:5000"
```
ansible-playbook -i inventory git.yml  

