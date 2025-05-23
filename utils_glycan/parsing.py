
from argparse import ArgumentParser,FileType

def parse_train_args():
    # General arguments
    parser = ArgumentParser()
    parser.add_argument('--config', type=FileType(mode='r'), default=None)
    parser.add_argument('--log_dir', type=str, default='workdir', help='Folder in which to save model and logs')
    parser.add_argument('--wandb_dir', type=str, default='wandb', help='Folder in which to save wandb logs')
    parser.add_argument('--restart_dir', type=str, help='Folder of previous training model from which to restart')
    parser.add_argument('--cache_path', type=str, default='data/cache', help='Folder from where to load/restore cached dataset')
    parser.add_argument('--data_dir', type=str, default='data/PDBBind_processed/', help='Folder containing original structures')
    parser.add_argument('--split_train', type=str, default='data/splits/timesplit_no_lig_cpu().detach()overlap_train', help='Path of file defining the split')
    parser.add_argument('--split_val', type=str, default='data/splits/timesplit_no_lig_overlap_val', help='Path of file defining the split')
    parser.add_argument('--split_test', type=str, default='data/splits/timesplit_test', help='Path of file defining the split')
    parser.add_argument('--test_sigma_intervals', action='store_true', default=False, help='Whether to log loss per noise interval')
    parser.add_argument('--val_inference_freq', type=int, default=5, help='Frequency of epochs for which to run expensive inference on val data')
    parser.add_argument('--skip_inference_freq', type=int, default=0, help='skip inference epochs')
    
    parser.add_argument('--train_inference_freq', type=int, default=None, help='Frequency of epochs for which to run expensive inference on train data')
    parser.add_argument('--inference_steps', type=int, default=20, help='Number of denoising steps for inference on val')
    
    parser.add_argument('--num_inference_complexes', type=int, default=100, help='Number of complexes for which inference is run every val/train_inference_freq epochs (None will run it on all)')
    parser.add_argument('--inference_earlystop_metric', type=str, default='valinf_rmsds_lt2', help='This is the metric that is addionally used when val_inference_freq is not None')
    parser.add_argument('--inference_earlystop_goal', type=str, default='max', help='Whether to maximize or minimize metric')
    parser.add_argument('--wandb', action='store_true', default=False, help='')
    parser.add_argument('--project', type=str, default='SurfDock_train', help='')
    parser.add_argument('--run_name', type=str, default='', help='')
    parser.add_argument('--cudnn_benchmark', action='store_true', default=False, help='CUDA optimization parameter for faster training')
    parser.add_argument('--num_dataloader_workers', type=int, default=0, help='Number of workers for dataloader')
    parser.add_argument('--pin_memory', action='store_true', default=False, help='pin_memory arg of dataloader')

    # Training arguments
    parser.add_argument('--n_epochs', type=int, default=1, help='Number of epochs for training')
    parser.add_argument('--batch_size', type=int, default=32, help='Batch size')
    parser.add_argument('--scheduler', type=str, default=None, help='LR scheduler')
    parser.add_argument('--scheduler_patience', type=int, default=20, help='Patience of the LR scheduler')
    parser.add_argument('--lr', type=float, default=1e-3, help='Initial learning rate')
    parser.add_argument('--restart_lr', type=float, default=None, help='If this is not none, the lr of the optimizer will be overwritten with this value when restarting from a checkpoint.')
    parser.add_argument('--w_decay', type=float, default=0.0, help='Weight decay added to loss')
    parser.add_argument('--num_workers', type=int, default=1, help='Number of workers for preprocessing')
    parser.add_argument('--use_ema', action='store_true', default=False, help='Whether or not to use ema for the model weights')
    parser.add_argument('--ema_rate', type=float, default=0.999, help='decay rate for the exponential moving average model parameters ')

    # Dataset
    parser.add_argument('--limit_complexes', type=int, default=0, help='If positive, the number of training and validation complexes is capped')
    parser.add_argument('--all_atoms', action='store_true', default=False, help='Whether to use the all atoms model')
    parser.add_argument('--receptor_radius', type=float, default=30, help='Cutoff on distances for receptor edges')
    parser.add_argument('--c_alpha_max_neighbors', type=int, default=10, help='Maximum number of neighbors for each residue')
    parser.add_argument('--atom_radius', type=float, default=5, help='Cutoff on distances for atom connections')
    parser.add_argument('--atom_max_neighbors', type=int, default=8, help='Maximum number of atom neighbours for receptor')
    parser.add_argument('--matching', action='store_false', default=True, help='matching or not in data processing')
    parser.add_argument('--matching_popsize', type=int, default=20, help='Differential evolution popsize parameter in matching')
    parser.add_argument('--matching_maxiter', type=int, default=20, help='Differential evolution maxiter parameter in matching')
    parser.add_argument('--max_lig_size', type=int, default=None, help='Maximum number of heavy atoms in ligand')
    parser.add_argument('--remove_hs', action='store_true', default=False, help='remove Hs')
    parser.add_argument('--num_conformers', type=int, default=1, help='Number of conformers to match to each ligand')
    parser.add_argument('--esm_embeddings_path', type=str, default=None, help='If this is set then the LM embeddings at that path will be used for the receptor features')
    parser.add_argument('--surface_path', type=str, default=None, help='surface information path')
    parser.add_argument('--ligand_embeddings_path', type=str, default=None, help='ligand embedding path')
    # Diffusion
    # transformStyle
    parser.add_argument('--transformStyle', type=str, default='diffdock', help='transformStyle',choices=['BERT','diffdock'])
    parser.add_argument('--tr_weight', type=float, default=0.33, help='Weight of translation loss')
    parser.add_argument('--rot_weight', type=float, default=0.33, help='Weight of rotation loss')
    parser.add_argument('--tor_weight', type=float, default=0.33, help='Weight of torsional loss')
    parser.add_argument('--rot_sigma_min', type=float, default=0.1, help='Minimum sigma for rotational component')
    parser.add_argument('--rot_sigma_max', type=float, default=1.65, help='Maximum sigma for rotational component')
    parser.add_argument('--tr_sigma_min', type=float, default=0.1, help='Minimum sigma for translational component')
    parser.add_argument('--tr_sigma_max', type=float, default=30, help='Maximum sigma for translational component')
    parser.add_argument('--tor_sigma_min', type=float, default=0.0314, help='Minimum sigma for torsional component')
    parser.add_argument('--tor_sigma_max', type=float, default=3.14, help='Maximum sigma for torsional component')
    parser.add_argument('--no_torsion', action='store_true', default=False, help='If set only rigid matching')
    # Model
    parser.add_argument('--num_conv_layers', type=int, default=2, help='Number of interaction layers')
    parser.add_argument('--max_radius', type=float, default=5.0, help='Radius cutoff for geometric graph')
    parser.add_argument('--scale_by_sigma', action='store_true', default=True, help='Whether to normalise the score')
    parser.add_argument('--ns', type=int, default=16, help='Number of hidden features per node of order 0')
    parser.add_argument('--nv', type=int, default=4, help='Number of hidden features per node of order >0')
    parser.add_argument('--distance_embed_dim', type=int, default=32, help='Embedding size for the distance')
    parser.add_argument('--cross_distance_embed_dim', type=int, default=32, help='Embeddings size for the cross distance')
    parser.add_argument('--no_batch_norm', action='store_true', default=False, help='If set, it removes the batch norm')
    parser.add_argument('--use_second_order_repr', action='store_true', default=False, help='Whether to use only up to first order representations or also second')
    parser.add_argument('--cross_max_distance', type=float, default=80, help='Maximum cross distance in case not dynamic')
    parser.add_argument('--dynamic_max_cross', action='store_true', default=False, help='Whether to use the dynamic distance cutoff')
    parser.add_argument('--dropout', type=float, default=0.0, help='MLP dropout')
    parser.add_argument('--embedding_type', type=str, default="sinusoidal", help='Type of diffusion time embedding')
    parser.add_argument('--sigma_embed_dim', type=int, default=32, help='Size of the embedding of the diffusion time')
    parser.add_argument('--embedding_scale', type=int, default=1000, help='Parameter of the diffusion time embedding')
    # mdn mode
    # loss terms
    parser.add_argument('--ligand_distance_prediction', action='store_true', default=False, help='can been used in mdn scoring model traing')
    parser.add_argument('--atom_type_prediction', action='store_true', default=False, help='used in mdn scoring model traing')
    parser.add_argument('--bond_type_prediction', action='store_true', default=False, help='used in mdn scoring model traing')
    parser.add_argument('--residue_type_prediction', action='store_true', default=False, help='can been used in mdn scoring model traing')
    parser.add_argument('--mdn_dist_threshold_train', type=float, default=7.0, help='mdn_dist_threshold_train')
    parser.add_argument('--mdn_dist_threshold_test', type=float, default=5.0, help='mdn_dist_threshold_test')
    # mdn mode
    parser.add_argument('--model_type',  type=str, default='score_model', help='model type',choices=['score_model','mdn_model','energy_score_model','surface_score_model'])
    # ConfidenceCGScoreModelV3
    parser.add_argument('--model_version', type=str, default='version3', help='version of mdn model')
    parser.add_argument('--topN', type=int, default=1, help='topN atoms with the smallest distances with surface node for mdn calculate! ')
    # early_stop_patience 
    parser.add_argument('--mdn_early_stop_patience', type=int, default=30 ,help='early stop epochs for mdn')
    parser.add_argument('--mdn_dropout', type=float, default=0.1, help='dropout rate for mdn')
    parser.add_argument('--n_gaussians', type=int, default=20, help='dropout rate for mdn')
    # tor_sigma_min
    args = parser.parse_args()
    return args
