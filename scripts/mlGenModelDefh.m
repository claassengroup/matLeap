function genModelDefh( filePath, sNr, rNr, thNr )
    outStr = sprintf('#ifndef MODEL_DEF_H_\n#define MODEL_DEF_H_\n#define THNR %d\n#define SPNR %d\n#define RENR %d\n#endif\n', thNr, sNr, rNr);

    fHandle = fopen(filePath, 'w');
    fwrite(fHandle, outStr);
    fclose(fHandle);
end

