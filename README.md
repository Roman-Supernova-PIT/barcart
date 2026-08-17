# barcart

`barcart` is an orchestration package for Roman WFI supernova discovery.

One could pretend that the name is an acronym:  
Batch And Run the Cosmology Analysis for the Roman Telescope.

In this alpha version, it will:
- run sidecar for image differencing and candidate detection,
- Pick a sample candidate from the detection catalog
- Send that candidate to phrosty and campari for follow-up photometry.

## Example scripts

### On SMDC
1. Create `${HOME}/snpit/packages`

```
mkdir -p ${HOME}/snpit/packages
2. Check out `snappl`, `sidecar`, `phrosty`, `campari`, and `barcart` into that directory

cd ${HOME}/snpit/packages
git clone https://github.com/Roman-Supernova-PIT/snappl
git clone https://github.com/Roman-Supernova-PIT/sidecar
git clone https://github.com/Roman-Supernova-PIT/phrosty
git clone https://github.com/Roman-Supernova-PIT/campari
git clone https://github.com/Roman-Supernova-PIT/barcart

3. Switch to appropriate branches as needed.  The `main` branches of both `sidecart` and `barcart` work.

```
cd ${HOME}/snpit/packages/snappl
git checkout u/rknop/2028photphest

cd ${HOME}/snpit/packages/phrosty
git checkout 203-update-smdc-test-config-for-new-container-less-smdc-environment

cd ${HOME}/snpit/packages/campari
git checkout SMDC_updates
```

4. Load container environment:

```
bash /data/snpit/env/environment_checkout_for_apptainer/singrun_smdc_ricksim.sh
```

5. Run script in container environment to perform subtraction and photometry of a selected candidate

```
cd ${HOME}/snpit
barcart/scripts/run_apptainer_example.sh
```
