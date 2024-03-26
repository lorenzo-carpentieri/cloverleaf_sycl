#ifndef KERNEL_MAP_HPP
#define KERNEL_MAP_HPP

#include <map>
#include <string>

class KernelMap {
public:
    static std::map<std::string, double>& getIntelMax1100FreqMap_PerKernel() {
        static std::map<std::string, double> intelMax1100FreqMap = {
           
            // Add more initializations if needed
        };
        return intelMax1100FreqMap;
    }
    
    static std::map<std::string, double>& getIntelMax1100FreqMap_PerApp() {
        static std::map<std::string, double> intelMax1100FreqMap = {
         
            // Add more initializations if needed
        };
        return intelMax1100FreqMap;
    }

    static std::map<std::string, double>& getNvidiaV100FreqMap() {
        static std::map<std::string, double> nvidiaV100FreqMap = {
            {"kernel3", 4.0},
            {"kernel4", 5.5}
            // Add more initializations if needed
        };
        return nvidiaV100FreqMap;
    }

    static std::map<std::string, double>& getAmdMI100FreqMap() {
        static std::map<std::string, double> amdMI100FreqMap = {
            {"kernel5", 6.0},
            {"kernel6", 7.5}
            // Add more initializations if needed
        };
        return amdMI100FreqMap;
    }
};

#endif /* KERNEL_MAP_HPP */


