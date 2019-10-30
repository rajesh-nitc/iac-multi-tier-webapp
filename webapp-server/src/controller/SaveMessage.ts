import { Request, Response } from "express";
import { getManager } from "typeorm";
import { SimpleMessage } from "../entity/SimpleMessage";

export async function SaveMessage(request: Request, response: Response) {

    const msgRepository = getManager().getRepository(SimpleMessage);
    const newMsg = msgRepository.create(request.body);
    await msgRepository.save(newMsg);
    response.send(newMsg);


}
