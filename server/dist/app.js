"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const bodyParser = require("body-parser");
const cors = require("cors");
const dotenv = require("dotenv");
const express = require("express");
require("reflect-metadata");
const typeorm_1 = require("typeorm");
const GetAllMessages_1 = require("./controller/GetAllMessages");
const SaveMessage_1 = require("./controller/SaveMessage");
const HelloWorld_1 = require("./controller/HelloWorld");
// if (process.env.NODE_ENV !== "production") dotenv.config();
dotenv.config();
typeorm_1.createConnection({
    type: "mysql",
    host: process.env.MYSQL_HOST,
    port: 3306,
    username: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DATABASE,
    entities: [__dirname + "/entity/**/*.js"],
    synchronize: true,
    logging: false,
}).then((connection) => __awaiter(this, void 0, void 0, function* () {
    const app = express();
    app.use(cors({ origin: true, credentials: true }));
    app.use(bodyParser.json());
    app.get("/api", HelloWorld_1.HelloWorld);
    app.get("/api/getmsg", GetAllMessages_1.GetAllMessages);
    app.post("/api/savemsg", SaveMessage_1.SaveMessage);
    app.listen(process.env.PORT);
    console.log(`server up at ${process.env.PORT}`);
})).catch((error) => console.log("connection error: ", error));
