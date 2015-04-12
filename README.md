# deformation-from-tagging
Implementation of a method to recover deformation and strain tensors from tagging MRI.

This project implements the a method to recover deformation tensors in MATLAB. This method was first presented by Bruurmijn et al. (2013). The bibtex entry is given below.

@inproceedings{DBLP:conf/fimh/BruurmijnKFDFFA13,
	Author = {L. C. Mark Bruurmijn and Hanne B. Kause and Olena G. Filatova and Remco Duits and Andrea Fuster and Luc Florack and Hans C. van Assen},
	Bibsource = {DBLP, http://dblp.uni-trier.de},
	Booktitle = {FIMH},
	Crossref = {DBLP:conf/fimh/2013},
	Ee = {http://dx.doi.org/10.1007/978-3-642-38899-6_34},
	Pages = {284-291},
	Title = {Myocardial Deformation from Local Frequency Estimation in Tagging MRI},
	Year = {2013}}
@proceedings{DBLP:conf/fimh/2013,
	Bibsource = {DBLP, http://dblp.uni-trier.de},
	Booktitle = {FIMH},
	Editor = {S{\'e}bastien Ourselin and Daniel Rueckert and Nicolas Smith},
	Ee = {http://dx.doi.org/10.1007/978-3-642-38899-6},
	Isbn = {978-3-642-38898-9},
	Publisher = {Springer},
	Series = {Lecture Notes in Computer Science},
	Title = {Functional Imaging and Modeling of the Heart - 7th International Conference, FIMH 2013, London, UK, June 20-22, 2013. Proceedings},
	Volume = {7945},
	Year = {2013}}

To run the code in this package the LTFAT library is needed. It can be downloaded at http://ltfat.sourceforge.net/download.php . Once this Matlab package is installed this directory should be added to the MATLAB path. To test if the code is correctly imported run the following command in MATLAB:
	
>> help deformationFromTagging

If no error message is printed the code should be ready for use. The directory ./gabor contains all functions related to calculating deformation and strain tensors from tagging MRI. The ./util package contains some helper and plotting functions.
