name: Production Deploy

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    env:
      DOCKER_BUILDKIT: 1
      RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY }}
      KAMAL_REGISTRY_USERNAME: ${{ secrets.KAMAL_REGISTRY_USERNAME }}
      KAMAL_REGISTRY_PASSWORD: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true

      - name: Instal kamal
        run: gem install kamal

      - uses: webfactory/ssh-agent@v0.8.0
        with:
          ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}

      - name: Set up Docker
        uses: docker/setup-buildx-action@v3
        with:
          platforms: linux/amd64

      - uses: docker/build-push-action@v5
        with:
          context: .
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Copy Config
        run: cp config/deploy.yml.prod config/deploy.yml

      - name: Deploy Application
        run: kamal deploy
