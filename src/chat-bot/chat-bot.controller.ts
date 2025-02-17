import { Controller, Body, Post,UsePipes,ValidationPipe } from '@nestjs/common';
import { ChatBotService } from './chat-bot.service';
import { GetAIMessageDTO } from './model/get-ai-response.dto';

@Controller('chat-bot')
export class ChatBotController {
    constructor(private readonly service :ChatBotService){}

    @Post('')
    @UsePipes(new ValidationPipe({ transform:true}))
    getResponse(@Body() data : GetAIMessageDTO){
        return this.service.generateText(data);
    }

}
