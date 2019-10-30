import { Request, Response } from "express";
import { getManager } from "typeorm";
import { SimpleMessage } from "../entity/SimpleMessage";

export async function GetAllMessages(request: Request, response: Response) {

    const msgRepository = getManager().getRepository(SimpleMessage);
    const allMsgs: any = await msgRepository.find()
    response.send(allMsgs);

}
