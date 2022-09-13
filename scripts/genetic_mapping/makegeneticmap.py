import numpy as np
import pandas as pd
from numba import njit
import argparse
import janitor
from tqdm import tqdm


def read_map_files(files: str) -> pd.DataFrame:
    '''
    files should be path with a ~ where the chromosome number should be
    '''
    files = files.split('~')
    dat = pd.DataFrame(columns = ['begin', 'end', 'cm', 'chr'])
    for chr in range(1, 23):
        dattmp = pd.read_csv(
            files[0] + str(chr) + files[1],
            delim_whitespace = True
        )
        dattmp.columns = dattmp.columns.str.lower()
        dattmp['chr'] = chr

        dattmp['bitlength'] =  dattmp['cm'] - dattmp['cm'].shift()
        dattmp.loc[0, 'bitlength'] = dattmp.loc[0, 'cm']
        dat = pd.concat([dat, dattmp])
    
    dat = dat.reset_index(drop = True)
    dat['begin'] = dat['begin'].astype(int)
    dat['end'] = dat['end'].astype(int)
    dat['chr'] = dat['chr'].astype(int)
    
    
    return dat


def get_genome_length(dat: pd.DataFrame) -> float:
    '''
    Pass in data frame from read_map_files and get
    length of entire genome
    '''

    genomelength = dat['bitlength'].sum()
    return genomelength

def make_segments(dat: pd.DataFrame, segmentsize: float) -> pd.DataFrame:
    '''
    Divides up genetic map into bits 
    based on segment lengths.

    Algorithm for each segment:
    segmentsizetillnow = 0
    i = 0
    while segmentsizetillnow < segmentsize:
        segmentsizetillnow += bitlength[i]
    '''


    datsegments = dat.copy()
    cm = datsegments['bitlength'].values
    datsegments['segmentid'] = make_segments_core(cm, segmentsize)
        
    return datsegments

@njit(cache=True)
def make_segments_core(cm: np.array, segmentsize: float) -> np.array:
    '''
    jitted core to make segments
    '''

    snpstart = 0
    segmentid = 1
    segmentsizetillnow = 0
    datsegments = np.zeros(cm.shape, dtype=np.int64)
    for i in range(datsegments.shape[0]):
        segmentsizetillnow += cm[i]
        if segmentsizetillnow >= segmentsize:
            datsegments[snpstart:i] = segmentid
            segmentid += 1
            snpstart = i
            segmentsizetillnow = cm[i]
    
    return datsegments


def merge_rsid(dat: pd.DataFrame, rsids: pd.DataFrame, nchunks: int =5000) -> pd.DataFrame:
    '''
    Chunkwise conditional joining because of memory issues
    '''
    all_data = pd.DataFrame()
    dfchunks = np.array_split(dat, nchunks)
    for df in tqdm(dfchunks):
        datjoined = df.conditional_join(rsids, ('begin', 'pos', '<='), ('end', 'pos', '>'), ('chr', 'chromosome', '=='))
        del datjoined['chromosome']
        all_data = pd.concat([all_data, datjoined], ignore_index=True, sort=False)
    
    return all_data


def get_rsid(dat: pd.DataFrame, rsidfiles: str) -> pd.DataFrame:
    '''
    Makes data file from map file format to
    a dataframe with each observation as one snp
    with an rsid read from rsidfiles
    '''

    print("Getting rsids...")
            
    rsids = pd.read_csv(
        rsidfiles,
        delim_whitespace = True,
        dtype = {"rsmid" : str, "chr" : str, "pos" : np.int64}
    ).rename(columns = {'chr' : 'chromosome'})

    rsids = rsids.loc[rsids["chromosome"] != "X"]
    rsids["chromosome"] = rsids["chromosome"].map(int)

    # splitting dataframe
    datsegments = merge_rsid(dat, rsids)

    return datsegments

def merge_sumstat(segmentdata, sumstat, nchunks = 5000):
    '''
    Merging segmentdata with summary statistics
    '''

    if args.getrsid:
        datout = pd.merge(datout, sumstats, on="SNP", how="left")
    else:
        datout = pd.DataFrame()
        dfchunks = np.array_split(segmentdata, nchunks)
        for df in tqdm(dfchunks):
            datjoined = df.conditional_join(sumstat, ('begin', 'pos', '<='), ('end', 'pos', '>'), ('chr', 'chromosome', '=='))
            del datjoined['chromosome']
            datout = pd.concat([datout, datjoined], ignore_index=True, sort=False)

    return datout


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('rawmap', type=str, help = "Path to map file. Replace chromosme number in the file with ~")
    parser.add_argument('--nsegments', type=float, default=1000000, help = "Number of segments to divide into. Default is 1 million.")
    parser.add_argument('--getrsid', type=bool, default=False, help = "Should RSIDs be made/matched")
    parser.add_argument('--rsidfile', type=str, default="/var/genetics/ukb/linner/EA3/EasyQC_HRC/EASYQC.RSMID.MAPFILE.HRC.chr1_22_X.txt",
                         help = "File to get rsids from. Default is HRC file")
    parser.add_argument('--sumstat', type=str, help = "Sumstats to be merged with")
    parser.add_argument('--outprefix', type=str, default="./rsid_segments.txt", help = "Outpath prefix.")
    args = parser.parse_args()
                        
    files = args.rawmap
    dat = read_map_files(files)
    glen = get_genome_length(dat)
    segmentsize = glen/args.nsegments
    datout = make_segments(dat, segmentsize)
    if args.getrsid:
        datout = get_rsid(datout, args.rsidfile)
    
    if args.sumstat is not None:
        sumstats = pd.read_csv(args.sumstat, delim_whitespace=True)
        datout = merge_sumstat(datout, sumstats)
        idx = datout.groupby('segmentid')['direct_N'].idxmax()
        datout = datout.loc[idx, ['segmentid', 'SNP', 'chr', 'pos', 'direct_N', 'A1', 'A2']] 
        
    datout.to_csv(args.outprefix + '.gz', sep = ' ', na_rep = 'nan', index=False)
    datout[['SNP', 'A1', 'A2']].to_csv(args.outprefix + '.ldscsnplist', sep = ' ', na_rep = 'nan', index=False)



