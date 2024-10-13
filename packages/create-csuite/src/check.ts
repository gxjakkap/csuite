import { exec } from "node:child_process";
import { promisify } from "node:util"

const pExec = promisify(exec)

export const checkForCommand = async (cmd: string, exp: string) => {
    try {
        const { stdout } = await pExec(cmd);
        if (!stdout.startsWith(exp)) return false;

        const versionMatch = stdout.match(/(\d+\.\d+(\.\d+)?)/);
        return versionMatch ? versionMatch[0] : false;
    } catch (error) {
        return false;
    }
};