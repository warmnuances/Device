import { AzureFunction, Context, HttpRequest } from "@azure/functions";
import { type Knex } from "knex";

interface Device {
  deviceId: string;
  name: string;
  location: string;
  type: string;
  assetId: string;
}

const httpTrigger: AzureFunction = async function (
  context: Context,
  req: HttpRequest
): Promise<void> {
  const DB_URL = process.env["ConnectionStrings:DB_URL"];

  const db: Knex = require("knex")({
    client: "mysql2",
    connection: DB_URL,
  });

  context.log("DB_URL", DB_URL);
  context.log("method", req.method);

  try {
    switch (req.method) {
      case "GET":
        break;

      case "POST":
        context.log(req.body);

        context.res = {
          ...req.body,
          status: 201,
        };
        break;
      default:
        context.res = {
          body: "Method Not Supported",
          status: 405,
        };
    }
  } catch (e) {
    context.res = {
      status: 500,
      body: "Something went wrong" + e.message,
    };
  }
};

async function createDevice({ devices, db }: { db: Knex; devices: Device[] }) {
  await db.insert(devices).into("device");
}

export default httpTrigger;
