import prompts from "prompts";
import degit from "degit";
import chalk from "chalk";
import fs from "fs";
import yoctoSpinner from 'yocto-spinner';
import { platform, cwd } from "node:process";

const repo = "gxjakkap/csuite";

(async () => {
    try{
      console.log(chalk.bold(chalk.cyan(("Initiating CSuite Project!"))))
      console.log(chalk.whiteBright("Where should we initialize your project?"))
      const projnamePrompt = await prompts([
        {
          type: "text",
          name: "projName",
          message: chalk.gray("> Enter your project name (put in '.' to initiate project in current directory)"),
          initial: "csuite-project",
          format: (val) => val.toLowerCase().split(" ").join("-")
        },
      ]);

      const { projName } = projnamePrompt;
      let projDir = `${cwd()}`;

      if (projName !== ".") {
        projDir = `${projDir}/${projName}`;
        fs.mkdirSync(projDir);
      }

      if (platform === "win32"){
        const spinner = yoctoSpinner({text: chalk.cyan(`Generating project using template for ${chalk.underline("Windows")}`)}).start();
        // download scripts
        await degit(`${repo}/src/scripts/win`).clone(`${projDir}`);

        // download py script for testing
        await degit(`${repo}/src/py`).clone(`${projDir}/.csuite/test`);

        // download template
        await degit(`${repo}/src/template`).clone(`${projDir}/.csuite/template`);
        spinner.success(chalk.green(`Successfully generated project at ${projDir}`));
      }
    }
    catch(err: any){
      console.log(err.message);
    }
})()

//degit(`${repo}/src`)