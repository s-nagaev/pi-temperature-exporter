pub mod temperature {

    use std::fs::read_to_string;
    use std::num::ParseFloatError;
    use std::num::ParseIntError;
    use std::process::Command;

    const CPU_TEMP_FILE_PATH: &str = "/sys/class/thermal/thermal_zone0/temp";

    /// CPU temperature collector.
    /// Getting the CPU temperature from the file.
    ///
    /// If the specific file doesn't exist by any reason - returns 0.
    pub fn get_cpu_temperature() -> Result<f64, ParseIntError> {
        let str_data = match read_to_string(CPU_TEMP_FILE_PATH) {
            Ok(result) => result,
            Err(_) => return Ok(0 as f64),
        };

        let int_data: u32 = str_data.trim().parse()?;
        Ok(int_data as f64 / 1000 as f64)
    }

    /// GPU temperature collector.
    /// Getting the GPU temperature from the vcgencmd's output.
    /// The user, running this app must belongs to the "video" group.
    ///
    /// If can't get the temperature by any reason - returns 0.
    pub fn get_gpu_temperature() -> Result<f64, ParseFloatError> {
        let command_output = match Command::new("vcgencmd").arg("measure_temp").output() {
            Ok(r) => r,
            Err(_) => return Ok(0 as f64),
        };
        let cow_str_data = String::from_utf8_lossy(&command_output.stdout);
        let str_data: &str = &cow_str_data.into_owned();
        let re = regex::Regex::new(r"temp=(\d+\.\d+)").unwrap();
        let captures = re.captures(str_data).unwrap();
        let temperature: f64 = captures[1].parse().unwrap();
        Ok(temperature)
    }
}
