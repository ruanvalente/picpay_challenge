# Use a imagem base Ruby 3.1.2
FROM ruby:3.1.2

# Defina o diretório de trabalho dentro do contêiner
WORKDIR /app

# Copie o Gemfile e o Gemfile.lock para o diretório de trabalho
COPY Gemfile Gemfile.lock ./

# Instale as gemas
RUN gem install bundler && bundle install

# Copie todo o código-fonte da sua aplicação para o contêiner
COPY . .

# Exponha a porta em que sua aplicação Rails está sendo executada
EXPOSE 3000

# Defina as variáveis de ambiente necessárias para o Rails (por exemplo, o ambiente de execução)
ENV RAILS_ENV=development

# Execute a remoção do banco 
RUN rails db:drop

# Execute as migrações do banco de dados
RUN rails db:migrate

# Execute as seeds do banco de dados
RUN rails db:seed

# Execute o comando para iniciar sua aplicação Rails (por exemplo, um servidor web)
CMD ["rails", "server", "-b", "0.0.0.0"]
