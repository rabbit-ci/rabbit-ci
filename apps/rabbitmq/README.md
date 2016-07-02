RabbitMQ
========

OTP app for RabbitMQ based on the AMQP library. Pooling code taken largely from
[pma/phoenix_pubsub_rabbitmq](https://github.com/pma/phoenix_pubsub_rabbitmq).
To use, add RabbitMQ to mix.exs.

     {:rabbitmq, in_umbrella: true},

And also add `:rabbitmq` to your applications.

    [applications: [..., :rabbitmq], ...
