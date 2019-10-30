import { Request, Response } from "express";

export async function HelloWorld(request: Request, response: Response) {
    response.send({msg: "hello world!"});

}
