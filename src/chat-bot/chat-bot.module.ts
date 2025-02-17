import { Module } from '@nestjs/common';
import { ChatBotService } from './chat-bot.service';
import { ChatBotController } from './chat-bot.controller';

@Module({
  providers: [ChatBotService],
  controllers: [ChatBotController]
})
export class ChatBotModule {}
