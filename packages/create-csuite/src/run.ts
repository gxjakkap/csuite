import prompts from "prompts";
import degit from "degit";
import chalk from "chalk";
import fs from "fs";
import { exec } from "node:child_process";
import { promisify } from "node:util"
import yoctoSpinner from 'yocto-spinner';
import { platform, cwd } from "node:process";
import { checkForCommand } from "./check.js"

const repo = "gxjakkap/csuite";

const pExec = promisify(exec);

(async () => {
    try{
      console.log(chalk.bold(chalk.cyan(("Initiating CSuite Project!\n"))))
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
      console.log(" ");

      const { projName } = projnamePrompt;
      let projDir = `${cwd()}`;
      let overwriteDir = false;

      if (projName !== ".") {
        projDir = `${projDir}/${projName}`;
        fs.mkdirSync(projDir);
      }
      else {
        overwriteDir = true;
      }

      if (platform === "win32"){
        console.log(chalk.cyan(chalk.bold("Checking for required dependencies")))
        const gccCheckSpinner = yoctoSpinner({text: chalk.cyan(`Checking for ${chalk.underline("gcc")}`)}).start();
        const gccExists = await checkForCommand("gcc --version", "gcc")

        if (gccExists){
          gccCheckSpinner.success(chalk.green(`gcc found (${gccExists})`))
        }
        else {
          gccCheckSpinner.error(chalk.red(`gcc not found! You need download it later for csuite to work.`))
        }

        const pyCheckSpinner = yoctoSpinner({text: chalk.cyan(`Checking for ${chalk.underline("Python")}`)}).start();
        const pyExists = await checkForCommand("py --version", "Python")

        if (pyExists){
          pyCheckSpinner.success(chalk.green(`Python found (${pyExists})`))
        }
        else {
          pyCheckSpinner.error(chalk.red(`Python not found! You'll need it for test and testv.`))
        }

        console.log(" ");
        console.log(chalk.cyan(chalk.bold("Generating project and Installing tools")))

        const projGenSpinner = yoctoSpinner({text: chalk.cyan(`Generating project using template for ${chalk.underline("Windows")}`)}).start();
        
        const degitOptions: degit.Options = { force: overwriteDir }
        
        // download scripts
        await degit(`${repo}/src/scripts/win`, degitOptions).clone(`${projDir}`);

        // download py script for testing
        await degit(`${repo}/src/py`, degitOptions).clone(`${projDir}/.csuite/test`);

        // download template
        await degit(`${repo}/src/template`, degitOptions).clone(`${projDir}/.csuite/template`);
        projGenSpinner.success(chalk.green(`Successfully generated project at ${projDir}`));
        process.exit(0)
      }

      else if (platform === "linux"){
        console.log(chalk.cyan(chalk.bold("Checking for required dependencies")))
        const gccCheckSpinner = yoctoSpinner({text: chalk.cyan(`Checking for ${chalk.underline("gcc")}`)}).start();
        const gccExists = await checkForCommand("gcc --version", "gcc")

        if (gccExists){
          gccCheckSpinner.success(chalk.green(`gcc found (${gccExists})`))
        }
        else {
          gccCheckSpinner.error(chalk.red(`gcc not found! You need download it later for csuite to work.`))
        }

        const pyCheckSpinner = yoctoSpinner({text: chalk.cyan(`Checking for ${chalk.underline("Python")}`)}).start();
        const pyExists = await checkForCommand("python3 --version", "Python")

        if (pyExists){
          pyCheckSpinner.success(chalk.green(`Python found (${pyExists})`))
        }
        else {
          pyCheckSpinner.error(chalk.red(`Python not found! You'll need it for test and testv.`))
        }

        console.log(" ");
        console.log(chalk.cyan(chalk.bold("Generating project and Installing tools")))

        const projGenSpinner = yoctoSpinner({text: chalk.cyan(`Generating project using template for ${chalk.underline("Linux")}`)}).start();
        
        const degitOptions: degit.Options = { force: overwriteDir }
        
        // download scripts
        await degit(`${repo}/src/scripts/linux`, degitOptions).clone(`${projDir}`);
        await pExec(`for file in *.sh; do mv "$file" "${"$"}{file%.sh}" done`)

        // download py script for testing
        await degit(`${repo}/src/py`, degitOptions).clone(`${projDir}/.csuite/test`);

        // download template
        await degit(`${repo}/src/template`, degitOptions).clone(`${projDir}/.csuite/template`);
        projGenSpinner.success(chalk.green(`Successfully generated project at ${projDir}`));
        process.exit(0)
      }
    }
    catch(err: any){
      console.log(err.message);
    }
})()

//degit(`${repo}/src`)