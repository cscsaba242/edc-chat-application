/*
 * Copyright (c)  2024 smartSense Consulting Solutions Pvt. Ltd.
 */

package com.smartsense.chat;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.web.bind.annotation.CrossOrigin;

@SpringBootApplication(scanBasePackages = {"com.smartsense", "com.smartsensesolutions"})
@ConfigurationPropertiesScan
@EnableFeignClients
@EnableAsync
public class EdcChatApplication {

    public static void main(String[] args) {
        SpringApplication.run(EdcChatApplication.class, args);
    }

}
