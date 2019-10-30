import * as bodyParser from "body-parser";
import cors = require("cors");
import * as dotenv from "dotenv"
import * as express from "express";
import "reflect-metadata";
import { createConnection } from "typeorm";
import { GetAllMessages } from "./controller/GetAllMessages";
import { SaveMessage } from "./controller/SaveMessage";
import { HelloWorld } from "./controller/HelloWorld";
// dotenv.config();
createConnection(
    {
        type: "mysql",
        host: process.env.MYSQL_HOST,
        port: 3306,
        username: process.env.MYSQL_USER,
        password: process.env.MYSQL_PASSWORD,
        database: process.env.MYSQL_DATABASE,
        entities: [__dirname + "/entity/**/*.js"],
        synchronize: true,
        logging: false,
    },
).then(async (connection) => {
    const app = express();
    app.use(cors({ origin: true, credentials: true }));
    app.use(bodyParser.json());
    app.get("/api", HelloWorld)
    app.get("/api/getmsg", GetAllMessages)
    app.post("/api/savemsg", SaveMessage)
    app.listen(process.env.PORT);
    console.log(`server up at ${process.env.PORT}`);

}).catch((error) => console.log("connection error: ", error));
