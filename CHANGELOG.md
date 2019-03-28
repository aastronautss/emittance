# emittance changelog

## 2.0.0
- Drop support for ruby versions < 2.2
- Add support for multiple brokers
- Add the "topical" routing strategy, which mimicks RabbitMQ's topic queue routing
- Add optional event validation middleware
- Add `#to_h` and `.from_h` to `Emittance::Event` for automatic serialization
