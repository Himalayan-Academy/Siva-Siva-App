import {bindRegionSelector, showScreen} from './functions.js';

export function bootstrap() {

        console.log("boot loaded.")

        showScreen("region_select")
        bindRegionSelector()

        console.log("end of boot sequence")

}