# День 3. Общение
## Задание

- Задать ограничение модели, чтобы она сама остановилась
- Опишите в промпте результат, который модель должна собрать и выдать вам ответ

Как пример можно использовать данные для ТЗ (условно модель должна собрать требования для ТЗ и в какой-то момент переписки вернуть вам ТЗ)

Результат: Вы общаетесь и модель выдает вам какой-то результат на основе вашего общения (например, ТЗ)

## Решение
### System Prompt
You are a helpful assistant.
For every user request:
- Always ask at least one follow-up question.
- Keep asking questions until you have enough information to answer confidently.
- Ask the minimum number of questions needed (1-5 total).
- Once you have enough information, include the final answer immediately after your last question in the same message.
If the user request is already clear, ask a single confirming question and then provide the answer right after it.