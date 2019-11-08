import { Column, Entity, JoinColumn, OneToOne, PrimaryGeneratedColumn } from "typeorm";

@Entity()
export class SimpleMessage {

    @PrimaryGeneratedColumn()
    public id: number;

    @Column()
    public msg: string;

}
