﻿using UnityEngine;
using UnityEngine.UI;

public class SkinPreview : MonoBehaviour 
{
    public float maxSkinAngle = 10f;
    public float skinRotationSpeed = 1.5f;
    
    public float maxHandsAngle = 5f;
    public float handsRotationSpeed = 7f;
    
    public float maxFrameDelay = 0.07f;
    private float currentFrameDelay = 0f;
    private int currentFrame = 0;
    
	private string[] limbsNames = {
		"left_hand", 
		"right_hand", 
		"left_leg", 
		"right_leg"
	};    
    
    private Image bodyImage;
    private Sprite[] bodyFrames;
    private GameObject leftHand;
    private GameObject rightHand;
    private GameObject leftLeg;
    private GameObject rightLeg;
    
    public Text RingText; 
    
    private int currentSkinID = 1;
    private int SKINS_COUNT = 10;
    
    public Image selectedImage;
    
    public bool [] purchasedSkins;
    public GameObject priceText;
    
	void Start () 
    {
        purchasedSkins = new bool [SKINS_COUNT];
        purchasedSkins[0] = purchasedSkins[1] = true;
        for (int i = 2; i < SKINS_COUNT; ++i)
        {
            purchasedSkins[i] = System.Convert.ToBoolean(PlayerPrefs.GetInt("skin_" + (i + 1).ToString(), 0));
            if (Cheats.UNLOCK_ALL_CHARACTERS)
                purchasedSkins[i] = true;
        }
        
        leftHand = transform.Find("left_hand").gameObject;
        rightHand = transform.Find("right_hand").gameObject;
        leftLeg = transform.Find("left_leg").gameObject;
        rightLeg = transform.Find("right_leg").gameObject;
                
        bodyFrames = new Sprite[2];
        bodyImage = transform.Find("main").GetComponent<Image>();
        
        SetSkin(PlayerPrefs.GetInt("current_skin", currentSkinID));
	}
    
    void SetSkin(int id)
    {
        id = Mathf.Clamp(id, 1, SKINS_COUNT);
        currentSkinID = id;
        
        var selectButton = GameObject.Find("select").GetComponent<Button>();
        
        string caption = LocalizedStrings.GetString(StringType.Purchase);

        priceText.SetActive(true);
        if (purchasedSkins[currentSkinID - 1])
        {
            caption = LocalizedStrings.GetString(StringType.Select);
            priceText.SetActive(false);
        }
        selectButton.GetComponentInChildren<Text>().text = caption;
        
        // Стрелки
        if (currentSkinID == 1)
        {
            GameObject.Find("LeftArrow").GetComponent<Button>().interactable = false;
        }
        else if(currentSkinID == SKINS_COUNT)
        {
            GameObject.Find("RightArrow").GetComponent<Button>().interactable = false;
        }
        else
        {
            GameObject.Find("LeftArrow").GetComponent<Button>().interactable = true;
            GameObject.Find("RightArrow").GetComponent<Button>().interactable = true;
        }
        
        // Загрузка текстур
        var bodyTexture1 = (Texture2D)Resources.Load<Texture>("skins/" + id.ToString() + "/main1");
        if (bodyTexture1 == null)
        {
            Debug.Log("Error loading skin: " + id);
            return;
        }
        var bodyTexture2 = (Texture2D)Resources.Load<Texture>("skins/" + id.ToString() + "/main2");
        if (bodyTexture2 == null)
        {
            Debug.Log("Error loading skin: " + id);
            return;
        }
        bodyFrames[0] = Sprite.Create(bodyTexture1, new Rect(0, 0, bodyTexture1.width, bodyTexture1.height), Vector2.zero);
        bodyFrames[1] = Sprite.Create(bodyTexture2, new Rect(0, 0, bodyTexture2.width, bodyTexture2.height), Vector2.zero);
        
        bodyImage.sprite = bodyFrames[0];
        foreach (var name in limbsNames)
        {
            var image = transform.Find(name).GetComponent<Image>();
            var texture = (Texture2D)Resources.Load<Texture>("skins/" + id.ToString() + "/" + name + "_ok");
            image.sprite = Sprite.Create(texture, new Rect(0, 0, texture.width, texture.height), Vector2.zero);
        }        
        
        // Отображение выбранного скина
        if (PlayerPrefs.GetInt("current_skin", 1) == id)
        {
            selectedImage.gameObject.SetActive(true);
            selectButton.interactable = false;
        }
        else
        {
            selectedImage.gameObject.SetActive(false);
            selectButton.interactable = true;
        }
    }
    
	void Update () 
    {
       RingText.text = CoinsManager.Balance.ToString();
        
       transform.localRotation = Quaternion.Euler(0, 0, Mathf.Sin(Time.time * skinRotationSpeed) * maxSkinAngle);
       
       var handsAngle = Mathf.Sin(Time.time * handsRotationSpeed) * maxHandsAngle;
       leftHand.transform.localRotation = Quaternion.Euler(0, 0, handsAngle);
       rightHand.transform.localRotation = Quaternion.Euler(0, 0, -handsAngle);
       
       leftLeg.transform.localRotation = Quaternion.Euler(0, 0, -handsAngle);
       rightLeg.transform.localRotation = Quaternion.Euler(0, 0, handsAngle);
       
       if (Input.GetKeyDown(KeyCode.LeftArrow))
       {
           PreviousSkin();
       }
       else if (Input.GetKeyDown(KeyCode.RightArrow))
       {
           NextSkin();
       }
       else if (Input.GetKeyDown(KeyCode.Return) || Input.GetKeyDown(KeyCode.Space))
       {
           SelectSkin();
       }
       
       // Анимация
       if (currentFrameDelay > 0)
       {
           currentFrameDelay -= Time.deltaTime;
       }
       else
       {
           currentFrameDelay = maxFrameDelay;
           
           // Следующий кадр
           currentFrame++;
           if(currentFrame >= bodyFrames.Length)
           {
               currentFrame = 0;
           }
           
           bodyImage.sprite = bodyFrames[currentFrame];
       }
       
        if (!purchasedSkins[currentSkinID - 1])
            GameObject.Find("select").GetComponent<Button>().interactable = (CoinsManager.Balance >= 50);
	}
    
    public void NextSkin()
    {
        SetSkin(currentSkinID + 1);
    }
    
    public void PreviousSkin()
    {
        SetSkin(currentSkinID - 1);
    }
    
    public void SelectSkin()
    {
        if (!purchasedSkins[currentSkinID - 1])
        {
            if(CoinsManager.Balance < 50)
            {
                Debug.LogWarning("Not enough coins!");
                return;
            }
            CoinsManager.Balance -= 50;
            purchasedSkins[currentSkinID - 1] = true;
            PlayerPrefs.SetInt("skin_" + (currentSkinID).ToString(), 1);
            PlayerPrefs.Save();
            
            SetSkin(currentSkinID);
            
            return;
        }
        
        PlayerPrefs.SetInt("current_skin", currentSkinID);
        SetSkin(currentSkinID);
        
        PlayerPrefs.Save();
    }
}
