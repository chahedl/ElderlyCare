import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ChatBotModule } from './chat-bot/chat-bot.module';
import { ConfigModule } from '@nestjs/config';

@Module({
  imports: [ChatBotModule,ConfigModule.forRoot({isGlobal:true})],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
