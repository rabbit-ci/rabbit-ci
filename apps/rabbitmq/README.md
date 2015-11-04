RabbitMQ
========

OTP app for RabbitMQ pool that uses the AMQP package (look there for AMQP docs,
this is just the pool). To use, add RabbitMQ to mix.exs.

     {:rabbitmq, in_umbrella: true},

And also add `:rabbitmq` to your applications.

    [applications: [..., :rabbitmq], ...

Look in BuildMan to see how the pool is used.
