import { AzureFunction, Context, HttpRequest } from "@azure/functions";
import { knex, Knex } from "knex";
import { readFileSync } from "fs";

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

  context.log("ssl dir", __dirname);

  const db: Knex = knex({
    client: "mysql",
    connection: {
      host: process.env["ConnectionStrings:DB_HOST"],
      password: process.env["ConnectionStrings:DB_PASSWORD"],
      user: process.env["ConnectionStrings:DB_USER"],
      database: process.env["ConnectionStrings:DB_NAME"],
      port: 3306, 
      ssl: {
        rejectUnauthorized: false,
        ca: [
          readFileSync("/local/var/www/html/BaltimoreCyberTrustRoot.crt.pem", "utf8"),
        ],
      },
    },
  });

  try {
    switch (req.method) {
      case "GET":
        break;

      case "POST":
        context.log(req.body);
        if (!req.body?.devices) {
          context.res = {
            body: "Bad Request",
            status: 400,
          };
        }

        const { devices } = req.body;
        await createDevice({ db, devices });

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

async function createDevice({ db, devices }: { db: Knex; devices: Device[] }) {
  await db.insert(devices).into("device");
}

export default httpTrigger;
