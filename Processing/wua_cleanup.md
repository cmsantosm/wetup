```bash
/home/csantosm/wetup/reads/
mkdir wua

mv raw* wua
mv rmphix* wua
mv trimmed* wua
mv un* wua

cd wua
mv raw raw1
mv trimmed trimmed1
mv rmphix rmphix1
mv rmphix_unpaired rmphix_unpaired1
mv unpaired unpaired1

cd /home/csantosm/wetup
mv sampleIDs.txt wua_sampleIDs.txt
mv virIDs.txt wua_virIDs.txt
mv tmgIDs.txt wua_tmgIDs.txt

mkdir prel_ids
mv virID* prel_ids
mv tmpIDs.txt prel_ids
mv sampleIDs* prel_ids
mv test* prel_ids
```
